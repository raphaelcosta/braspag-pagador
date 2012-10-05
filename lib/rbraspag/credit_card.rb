module Braspag
  class CreditCard < PaymentMethod

    MAPPING = {
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

    AUTHORIZE_URI = "/webservices/pagador/Pagador.asmx/Authorize"
    CAPTURE_URI = "/webservices/pagador/Pagador.asmx/Capture"
    CANCELLATION_URI = "/webservices/pagador/Pagador.asmx/VoidTransaction"
    PRODUCTION_INFO_URI   = "/webservices/pagador/pedido.asmx/GetDadosCartao"
    HOMOLOGATION_INFO_URI = "/pagador/webservice/pedido.asmx/GetDadosCartao"

    def self.authorize(params = {})
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

    def self.capture(order_id)
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

    def self.void(order_id)
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

    def self.info(order_id)
      connection = Braspag::Connection.instance

      raise InvalidOrderId unless self.valid_order_id?(order_id)

      data = {:loja => connection.merchant_id, :numeroPedido => order_id.to_s}
      response = Braspag::Poster.new(self.info_url).do_post(:info_credit_card, data)

      response = Utils::convert_to_map(response.body, {
          :checking_number => "NumeroComprovante",
          :certified => "Autenticada",
          :autorization_number => "NumeroAutorizacao",
          :card_number => "NumeroCartao",
          :transaction_number => "NumeroTransacao"
        })

      raise UnknownError if response[:checking_number].nil?
      response
    end

    def self.check_params(params)
      super

      [:customer_name, :holder, :card_number, :expiration, :security_code, :number_payments, :type].each do |param|
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

      raise InvalidSecurityCode if params[:security_code].to_s.size < 1 || params[:security_code].to_s.size > 4

      raise InvalidNumberPayments if params[:number_payments].to_i < 1 || params[:number_payments].to_i > 99
    end

    # <b>DEPRECATED:</b> Please use <tt>ProtectedCreditCard.save</tt> instead.
    def self.save(params)
      warn "[DEPRECATION] `CreditCard.save` is deprecated.  Please use `ProtectedCreditCard.save` instead."
      ProtectedCreditCard.save(params)
    end

    # <b>DEPRECATED:</b> Please use <tt>ProtectedCreditCard.get</tt> instead.
    def self.get(just_click_key)
      warn "[DEPRECATION] `CreditCard.get` is deprecated.  Please use `ProtectedCreditCard.get` instead."
      ProtectedCreditCard.get(just_click_key)
    end

    # <b>DEPRECATED:</b> Please use <tt>ProtectedCreditCard.just_click_shop</tt> instead.
    def self.just_click_shop(params = {})
      warn "[DEPRECATION] `CreditCard.just_click_shop` is deprecated.  Please use `ProtectedCreditCard.just_click_shop` instead."
      ProtectedCreditCard.just_click_shop(params)
    end

    def self.info_url
      connection = Braspag::Connection.instance
      connection.braspag_url + (connection.production? ? PRODUCTION_INFO_URI : HOMOLOGATION_INFO_URI)
    end

    def self.authorize_url
      Braspag::Connection.instance.braspag_url + AUTHORIZE_URI
    end

    def self.capture_url
      Braspag::Connection.instance.braspag_url + CAPTURE_URI
    end

    def self.cancellation_url
      Braspag::Connection.instance.braspag_url + CANCELLATION_URI
    end
  end
end
