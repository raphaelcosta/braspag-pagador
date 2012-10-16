require "bigdecimal"

module Braspag
  class Bill < PaymentMethod

    PAYMENT_METHODS = {
      :bradesco => "06",
      :cef => "07",
      :hsbc => "08",
      :bb => "09",
      :real => "10",
      :citibank => "13",
      :itau => "14",
      :unibanco => "26"
    }

    MAPPING = {
      :merchant_id => "merchantId",
      :order_id => "orderId",
      :customer_name => "customerName",
      :customer_id => "customerIdNumber",
      :amount => "amount",
      :payment_method => "paymentMethod",
      :number => "boletoNumber",
      :instructions => "instructions",
      :expiration_date => "expirationDate",
      :emails => "emails"
    }

    PRODUCTION_INFO_URI   = "/webservices/pagador/pedido.asmx/GetDadosBoleto"
    HOMOLOGATION_INFO_URI = "/pagador/webservice/pedido.asmx/GetDadosBoleto"
    CREATION_URI = "/webservices/pagador/Boleto.asmx/CreateBoleto"

    def self.generate(params)
      connection = Braspag::Connection.instance
      params[:merchant_id] = connection.merchant_id

      params = self.normalize_params(params)
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

      request = ::HTTPI::Request.new(self.creation_url)
      request.body = data

      response = Utils::convert_to_map(::HTTPI.post(request).body,
        {
          :url => nil,
          :amount => nil,
          :number => "boletoNumber",
          :expiration_date => Proc.new { |document|
            begin
              Date.parse(document.search("expirationDate").first.to_s)
            rescue
              nil
            end
          },
          :return_code => "returnCode",
          :status => nil,
          :message => nil
        })

      raise InvalidMerchantId if response[:message] == "Invalid merchantId"
      raise InvalidAmount if response[:message] == "Invalid purchase amount"
      raise InvalidPaymentMethod if response[:message] == "Invalid payment method"
      raise InvalidStringFormat if response[:message] == "Input string was not in a correct format."
      raise UnknownError if response[:status].nil?

      response[:amount] = BigDecimal.new(response[:amount])

      response
    end

    def self.normalize_params(params)
      params = super

      if params[:expiration_date].respond_to?(:strftime)
        params[:expiration_date] = params[:expiration_date].strftime("%d/%m/%y")
      end

      params
    end

    def self.check_params(params)
      super

      if params[:number]
        raise InvalidNumber unless (1..255).include?(params[:number].to_s.size)
      end

      if params[:instructions]
        raise InvalidInstructions unless (1..512).include?(params[:instructions].to_s.size)
      end

      if params[:expiration_date]
        matches = params[:expiration_date].to_s.match /(\d{2})\/(\d{2})\/(\d{2})/
        raise InvalidExpirationDate unless matches
        begin
          Date.new(matches[3].to_i, matches[2].to_i, matches[1].to_i)
        rescue ArgumentError
          raise InvalidExpirationDate
        end
      end
    end

    def self.info_url
      connection = Braspag::Connection.instance
      connection.braspag_url + (connection.production? ? PRODUCTION_INFO_URI : HOMOLOGATION_INFO_URI)
    end

    def self.creation_url
      Braspag::Connection.instance.braspag_url + CREATION_URI
    end

    def self.info(order_id)
      connection = Braspag::Connection.instance

      raise InvalidOrderId unless self.valid_order_id?(order_id)

      request = ::HTTPI::Request.new(self.info_url)
      request.body = {
        :loja => connection.merchant_id,
        :numeroPedido => order_id.to_s
      }

      response = ::HTTPI.post(request)

      response = Utils::convert_to_map(response.body, {
          :document_number => "NumeroDocumento",
          :payer => "Sacado",
          :our_number => "NossoNumero",
          :bill_line => "LinhaDigitavel",
          :document_date => "DataDocumento",
          :expiration_date => "DataVencimento",
          :receiver => "Cedente",
          :bank => "Banco",
          :agency => "Agencia",
          :account => "Conta",
          :wallet => "Carteira",
          :amount => "ValorDocumento",
          :amount_invoice => "ValorPago",
          :invoice_date => "DataCredito"
        })

      raise UnknownError if response[:document_number].nil?
      response
    end
  end
end
