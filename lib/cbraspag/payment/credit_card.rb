module Braspag
  class Connection
    def self.purchase(order, credit_card)
      response = self.authorize(order, credit_card)
      self.capture(order) if response.success?
    end

    MAPPING_CARD = {
      :merchant_id => "merchantId",
      :order => 'order',
      :order_id => "orderId",
      :customer_name => "customerName",
      :amount => "amount",
      :payment_method => "paymentMethod",
      :holder => "holder",
      :card_number => "cardNumber",
      :expiration => "expiration",
      :security_code => "securityCode",
      :number_payments => "numberPayments",
      :type => "typePayment",
    }


    def self.authorize(order, credit_card)
      return ::Response.new
      
      connection = Braspag::Connection.instance
      params[:merchant_id] = connection.merchant_id

      self.check_params(params)

      data = {}
      MAPPING.each do |k, v|
        case k
        when :payment_method
          data[v] = Braspag::Connection.instance.homologation? ? PAYMENT_METHODS[:braspag] : PAYMENT_METHODS[params[:payment_method]]
        when :amount
          data[v] = Utils.convert_decimal_to_string(params[:amount])
        else
          data[v] = params[k] || ""
        end
      end

      response = Braspag::Poster.new(self.authorize_url).do_post(:authorize, data)

      Utils::convert_to_map(response.body, {
          :amount => nil,
          :number => "authorisationNumber",
          :message => 'message',
          :return_code => 'returnCode',
          :status => 'status',
          :transaction_id => "transactionId"
        })
    end

    def self.capture(order)
      return ::Response.new
      
      connection = Braspag::Connection.instance
      merchant_id = connection.merchant_id

      raise InvalidOrderId unless self.valid_order_id?(order_id)

      data = {
        MAPPING[:order_id] => order_id,
        MAPPING[:merchant_id] => merchant_id
      }

      response = Braspag::Poster.new(self.capture_url).do_post(:capture, data)

      Utils::convert_to_map(response.body, {
          :amount => nil,
          :number => "authorisationNumber",
          :message => 'message',
          :return_code => 'returnCode',
          :status => 'status',
          :transaction_id => "transactionId"
        })
    end

    def self.void(order)
      return ::Response.new
      
      connection = Braspag::Connection.instance
      merchant_id = connection.merchant_id

      raise InvalidOrderId unless self.valid_order_id?(order_id)

      data = {
        MAPPING[:order] => order_id,
        MAPPING[:merchant_id] => merchant_id
      }

      response = Braspag::Poster.new(self.cancellation_url).do_post(:void, data)

      Utils::convert_to_map(response.body, {
          :amount => nil,
          :number => "authorisationNumber",
          :message => 'message',
          :return_code => 'returnCode',
          :status => 'status',
          :transaction_id => "transactionId"
        })
    end

    PROTECTED_CARD_MAPPING = {
      :request_id => "RequestId",
      :merchant_id => "MerchantKey",
      :customer_name => "CustomerName",
      :holder => "CardHolder",
      :card_number => "CardNumber",
      :expiration => "CardExpiration"
    }

    JUST_CLICK_MAPPING = {
      :request_id => "RequestId",
      :merchant_id => "MerchantKey",
      :customer_name => "CustomerName",
      :order_id => "OrderId",
      :amount => "Amount",
      :payment_method => "PaymentMethod",
      :number_installments => "NumberInstallments",
      :payment_type => "PaymentType",
      :just_click_key => "JustClickKey",
      :security_code => "SecurityCode"
    }


    # saves credit card in Braspag PCI Compliant
    def self.archive(credit_card, customer, request_id)
      return ::Response

      self.check_protected_card_params(params)

      data = { 'saveCreditCardRequestWS' => {} }

      PROTECTED_CARD_MAPPING.each do |k, v|
        data['saveCreditCardRequestWS'][v] = params[k] || ""
      end


     client = Savon::Client.new(self.save_protected_card_url)
     response = client.request(:web, :save_credit_card) do
       soap.body = data
     end

      response.to_hash[:save_credit_card_response][:save_credit_card_result]

    end

    # request the credit card info in Braspag PCI Compliant
    def self.get_recurrency(credit_card)
      return ::Response

      raise InvalidJustClickKey unless valid_just_click_key?(just_click_key)

      data = { 'getCreditCardRequestWS' => {:loja => connection.merchant_id, :justClickKey => just_click_key} }

      request = ::HTTPI::Request.new(self.get_protected_card_url)
      request.body = { 'getCreditCardRequestWS' => {:loja => connection.merchant_id, :justClickKey => just_click_key} }

      response = ::HTTPI.post(request)

      response = Utils::convert_to_map(response.body, {
          :holder => "CardHolder",
          :card_number => "CardNumber",
          :expiration => "CardExpiration",
          :masked_card_number => "MaskedCardNumber"
        })

      raise UnknownError if response[:card_number].nil?
      response
    end

    def self.recurrency(order, credit_card, request_id)
      return ::Response

      self.check_just_click_shop_params(params)

      order_id = params[:order_id]
      raise InvalidOrderId unless self.valid_order_id?(order_id)

      data = { 'justClickShopRequestWS' => {} }

      JUST_CLICK_MAPPING.each do |k, v|
        case k
        when :payment_method
          data['justClickShopRequestWS'][v] = Braspag::Connection.instance.homologation? ? PAYMENT_METHODS[:braspag] : PAYMENT_METHODS[params[:payment_method]]
        else
          data['justClickShopRequestWS'][v] = params[k] || ""
        end
      end

      client = Savon::Client.new(self.just_click_shop_url)
      response = client.request(:web, :just_click_shop) do
        soap.body = data
      end

      response.to_hash[:just_click_shop_response][:just_click_shop_result]

    end

    
  end
  
  
  class CreditCard
    include ::ActiveAttr::Model

    attr_accessor :holder_name, :number, :month, :year, :verification_value, :alias, :id

    [:purchase, :authorize, :archive].each do |check_on|
      validates :holder_name, :presence => { :on => check_on }
      validates :holder_name, :length => {:minimum => 1, :maximum => 100, :on => check_on}

      validates :number, :presence => { :on => check_on }
      
      validates :month, :presence => { :on => check_on }
      validates :month, :length => {:minimum => 1, :maximum => 2, :on => check_on}
      validates :year, :presence => { :on => check_on }
      validates :year, :length => {:is => 4, :on => check_on}
      
      #TODO CHECKAR SE A DATA é real
    end

    [:purchase, :authorize, :recurrency].each do |check_on|
      validates :verification_value, :presence => { :on => check_on }
      validates :verification_value, :length => {:minimum => 1, :maximum => 4, :on => check_on}
    end

    [:get_recurrency, :recurrency].each do |check_on|
      validates :id, :presence => { :on => check_on }
    end
    
    def self.valid_just_click_key?(just_click_key)
      (just_click_key.is_a?(String) && just_click_key.size == 36)
    end
    
   def self.check_protected_card_params(params)
      [:request_id, :customer_name, :holder, :card_number, :expiration].each do |param|
        raise IncompleteParams if params[param].nil?
      end

      raise InvalidHolder if params[:holder].to_s.size < 1 || params[:holder].to_s.size > 100

      matches = params[:expiration].to_s.match /^(\d{2})\/(\d{2,4})$/
      raise InvalidExpirationDate unless matches
      begin
        year = matches[2].to_i
        year = "20#{year}" if year.size == 2

        Date.new(year.to_i, matches[1].to_i)
      rescue ArgumentError
        raise InvalidExpirationDate
      end
    end

    def self.check_just_click_shop_params(params)
      just_click_shop_attributes = [:request_id, :customer_name, :order_id, :amount, :payment_method,
      :number_installments, :payment_type, :just_click_key, :security_code]

      just_click_shop_attributes.each do |param|
        raise IncompleteParams if params[param].nil?
      end

      raise InvalidSecurityCode if params[:security_code].to_s.size < 1 || params[:security_code].to_s.size > 4

      raise InvalidNumberInstallments if params[:number_installments].to_i < 1 || params[:number_installments].to_i > 99

    end
  end
end
