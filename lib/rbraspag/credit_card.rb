module Braspag
  class CreditCard < PaymentMethod

    PAYMENT_METHODS = {
      # BRASIL
      :amex_2p                  => 18,  # American Express 2 Party
      :cielo_noauth_visa        => 71,  # Cielo webservice captura automática sem autenticação - Visa
      :cielo_preauth_visa       => 73,  # Cielo webservice preauth sem autenticação - Visa
      :cielo_noauth_mastercard  => 120, # Cielo webservice captura automática sem autenticação - Mastercard
      :cielo_preauth_mastercard => 122, # Cielo webservice preauth sem autenticação - Mastercard
      :cielo_noauth_elo         => 126, # Cielo webservice captura automática sem autenticação - ELO
      :cielo_noauth_diners      => 130, # Cielo webservice captura automática sem autenticação - Diners
      :redecard                 => 20,  # Redecard Mastercard/Diners/Visa
      :redecard_preauth         => 42,  # Redecard preauth Mastercard/Diners/Visa
      :cielo_sitef              => 57,  # Cielo SITEF
      :hipercard_sitef          => 62,  # Hipercard SITEF
      :hipercard_moip           => 90,  # Hipercard MOIP
      :oi_paggo                 => 55,  # OiPaggo
      :amex_sitef               => 58,  # Amex SITEF
      :aura_dtef                => 37,  # Aura DTEF
      :redecard_sitef           => 44,  # Redecard SITEF - Mastercard/Diners
      # MÉXICO
      :mex_amex_2p            => 45, # American Express 2 Party
      :mex_banorte_visa       => 50, # Banorte Visa
      :mex_banorte_diners     => 52, # Banorte Diners
      :mex_banorte_mastercard => 53, # Banorte Mastercard
      # COLÔMBIA
      :col_visa   => 63, # Visa
      :col_amex   => 65, # Amex
      :col_diners => 66, # Diners
      # INTERNACIONAL
      :paypal_express => 35 # PayPal Express Checkout
    }

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

    PROTECTED_CARD_MAPPING = {
      :merchant_id => "merchantKey",
      :customer_name => "CustomerName",
      :holder => "CardHolder",
      :card_number => "CardNumber",
      :expiration => "CardExpiration",
      :order_id => "RequestId"
    }

    AUTHORIZE_URI = "/webservices/pagador/Pagador.asmx/Authorize"
    CAPTURE_URI = "/webservices/pagador/Pagador.asmx/Capture"
    CANCELLATION_URI = "/webservices/pagador/Pagador.asmx/VoidTransaction"
    SAVE_PROTECTED_CARD_URI = "/CartaoProtegido.asmx/SaveCreditCard"
    GET_PROTECTED_CARD_URI = "/CartaoProtegido.asmx/GetCreditCard"

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
          data[v] = PAYMENT_METHODS[params[:payment_method]]
        when :amount
          data[v] = Utils.convert_decimal_to_string(params[:amount])
        else
          data[v] = params[k] || ""
        end
      end

      request = ::HTTPI::Request.new self.authorize_url
      request.body = data

      response = ::HTTPI.post request
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

      request = ::HTTPI::Request.new(self.capture_url)
      request.body = data

      response = ::HTTPI.post(request)
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

      request = ::HTTPI::Request.new(self.cancellation_url)
      request.body = data

      response = ::HTTPI.post(request)
      Utils::convert_to_map(response.body, {
          :amount => nil,
          :number => "authorisationNumber",
          :message => 'message',
          :return_code => 'returnCode',
          :status => 'status',
          :transaction_id => "transactionId"
        })
    end

    def self.save(params = {})
      connection = Braspag::Connection.instance
      params[:merchant_id] = connection.merchant_id

      self.check_protected_card_params(params)

      order_id = params[:order_id]
      raise InvalidOrderId unless self.valid_order_id?(order_id)

      data = { 'saveCreditCardRequestWS' => {} }

      PROTECTED_CARD_MAPPING.each do |k, v|
        data['saveCreditCardRequestWS'][v] = params[k] || ""
      end

      request = ::HTTPI::Request.new(self.save_protected_card_url)
      request.body = data

      response = ::HTTPI.post(request)

      Utils::convert_to_map(response.body, {
          :just_click_key => "JustClickKey"
        })

    end


    def self.info(order_id)
      connection = Braspag::Connection.instance

      raise InvalidOrderId unless self.valid_order_id?(order_id)

      request = ::HTTPI::Request.new(self.info_url)
      request.body = {:loja => connection.merchant_id, :numeroPedido => order_id.to_s}

      response = ::HTTPI.post(request)

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

      matches = params[:expiration].to_s.match /^(\d{2})\/(\d{2}|\d{4})$/
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

    def self.check_protected_card_params(params)
      [:customer_name, :holder, :card_number, :expiration, :order_id].each do |param|
        raise IncompleteParams if params[param].nil?
      end

      raise InvalidHolder if params[:holder].to_s.size < 1 || params[:holder].to_s.size > 100

      matches = params[:expiration].to_s.match /^(\d{2})\/(\d{2}|\d{4})$/
      raise InvalidExpirationDate unless matches
      begin
        year = matches[2].to_i
        year = "20#{year}" if year.size == 2

        Date.new(year.to_i, matches[1].to_i)
      rescue ArgumentError
        raise InvalidExpirationDate
      end
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

    def self.save_protected_card_url
      Braspag::Connection.instance.braspag_url + SAVE_PROTECTED_CARD_URI
    end

    def self.get_protected_card_url
      Braspag::Connection.instance.braspag_url + GET_PROTECTED_CARD_URI
    end

  end
end
