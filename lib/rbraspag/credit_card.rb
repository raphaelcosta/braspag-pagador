module Braspag
  class CreditCard < PaymentMethod

    PAYMENT_METHODS = {
      # BRASIL
      :amex_2p                  => 18,  # American Express 2 Party
      :cielo_noauth_visa        => 71,  # Cielo webservice captura automática sem autenticação - Visa
      :cielo_preauth_visa       => 73,  # Cielo webservice preauth sem autenticação - Visa
      :cielo_noauth_mastercard  => 120, # Cielo webservice captura automática sem autenticação - Mastercard
      :cielo_preauth_mastercard => 122, # Cielo webservice preauth sem autenticação - Mastercard
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

    def self.uri_authorize
      "#{Braspag::Connection.instance.braspag_url}/webservices/pagador/Pagador.asmx/Authorize"
    end

    def self.uri_capture
      "#{Braspag::Connection.instance.braspag_url}/webservices/pagador/Pagador.asmx/Capture"
    end

    def self.authorize(params = {})
      connection = Braspag::Connection.instance
      params[:merchant_id] = connection.merchant_id

      [:order_id, :customer_name, :amount, :payment_method, :holder,
        :card_number, :expiration, :security_code, :number_payments, :type].each do |param|
        raise IncompleteParams unless params.include?(param)
      end

      raise InvalidOrderId unless (1..20).include?(params[:order_id].to_s.size)
      raise InvalidCustomerName unless (1..100).include?(params[:customer_name].to_s.size)
      raise InvalidAmount unless (1..10).include?(params[:amount].to_s.size)
      raise InvalidHolder unless (1..100).include?(params[:holder].to_s.size)
      raise InvalidExpirationDate unless (1..7).include?(params[:expiration].to_s.size)
      raise InvalidSecurityCode unless (1..4).include?(params[:security_code].to_s.size)
      raise InvalidNumberPayments unless (1..2).include?(params[:number_payments].to_s.size)
      raise InvalidType unless (1..2).include?(params[:type].to_s.size)

      params[:payment_method] = PAYMENT_METHODS[params[:payment_method]] if params[:payment_method].is_a?(Symbol)

      data =  MAPPING.inject({}) do |memo, k|
        if k[0] == :amount
          memo[k[1]] = Utils.convert_decimal_to_string(params[:amount])
        else
          memo[k[1]] = params[k[0]] || "";
        end
        memo
      end

      request = ::HTTPI::Request.new uri_authorize
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

      raise InvalidOrderId unless (1..20).include?(order_id.to_s.size)

      data = {MAPPING[:order_id] => order_id, "merchantId" => merchant_id }
      request = ::HTTPI::Request.new uri_capture

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


    def self.info(order_id)
      connection = Braspag::Connection.instance

      raise InvalidOrderId unless order_id.is_a?(String) || order_id.is_a?(Fixnum)
      raise InvalidOrderId unless (1..50).include?(order_id.to_s.size)

      request = ::HTTPI::Request.new("#{connection.braspag_query_url}/GetDadosCartao")
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


  end
end

