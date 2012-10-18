module Braspag
  class Connection
    def purchase(order, credit_card)
      response = self.authorize(order, credit_card)
      self.capture(order) if response.success?
    end

    def authorize(order, credit_card)
      data = {:merchant_id => self.merchant_id}
      data.merge!(credit_card.convert_to(:authorize).merge(order.convert_to(:authorize)))
      
      
      response = Braspag::Poster.new(self, self.url_for(:authorize))
                                .do_post(:authorize, Converter::to(:authorize, data))
      
      response = Converter::to_map(response.body, {
        :amount => nil,
        :number => "authorisationNumber",
        :message => 'message',
        :return_code => 'returnCode',
        :status => 'status',
        :transaction_id => "transactionId"
      })
      
      order.populate!(:authorize, response)
      
      status = (response[:status] == "0" || response[:status] == "1")

      Response.new(status,
                   response[:message],
                   response,
                   :test => homologation?,
                   :authorization => response[:number])
    end

    def capture(order)
      return Braspag::Response.new
      
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

    def void(order, partial=nil)
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
    def archive(credit_card, customer, request_id)
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
    def get_recurrency(credit_card)
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

    def recurrency(order, credit_card, request_id)
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

    class ExpiratorValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        begin
          year = record.year.try(:to_i)
          year = "20#{year}".to_i if year && year.to_s.size == 2

          month = record.month.try(:to_i)

          Date.new(year, month) if year && month
        rescue ArgumentError
          record.errors.add attribute, "invalid date"
        end
      end
    end


    [:purchase, :authorize, :archive].each do |check_on|
      validates :holder_name, :length => {:minimum => 1, :maximum => 100, :on => check_on}

      validates :number, :presence => { :on => check_on }
      
      validates :month, :presence => { :on => check_on }
      validates :month, :expirator => { :on => check_on }
      validates :year, :presence => { :on => check_on }
      validates :year, :expirator => { :on => check_on }
    end

    [:purchase, :authorize, :recurrency].each do |check_on|
      validates :verification_value, :length => {:minimum => 1, :maximum => 4, :on => check_on}
    end

    [:get_recurrency, :recurrency].each do |check_on|
      validates :id, :length => {:is => 36, :on => check_on}
    end
    
    def convert_to(method)
      self.send("to_#{method}")
    end
    
    def to_authorize
      year_normalize = year.to_s[-2, 2]
      {
        :holder          => self.holder_name.to_s,
        :card_number     => self.number.to_s,
        :expiration      => "#{self.month}/#{year_normalize}",
        :security_code   => self.verification_value.to_s,
      }
    end
    
    def populate!(method, response)
      
    end
  end
end
