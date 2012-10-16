module Braspag
  class Order
    PRODUCTION_INFO_URI   = "/webservices/pagador/pedido.asmx/GetDadosCartao"
    HOMOLOGATION_INFO_URI = "/pagador/webservice/pedido.asmx/GetDadosCartao"
    
    STATUS_PAYMENT = {
      :starting => "1",
      :close => "2",
      :paid => "3",
      :cancelled => "4"
    }
    
    def self.info_url_credit_card
      connection = Braspag::Connection.instance
      connection.braspag_url + (connection.production? ? PRODUCTION_INFO_URI : HOMOLOGATION_INFO_URI)
    end
    
    def self.info_credit_card(order_id)
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
    
    
    PRODUCTION_INFO_URI   = "/webservices/pagador/pedido.asmx/GetDadosPedido"
    HOMOLOGATION_INFO_URI = "/pagador/webservice/pedido.asmx/GetDadosPedido"

    def self.status(order_id)
      connection = Braspag::Connection.instance

      raise InvalidOrderId unless Braspag::PaymentMethod.valid_order_id?(order_id)

      request = ::HTTPI::Request.new(self.status_url)
      request.body = {
        :loja => connection.merchant_id, :numeroPedido => order_id.to_s
      }

      response = ::HTTPI.post(request)

      response = Utils::convert_to_map(response.body, {
        :authorization => "CodigoAutorizacao",
        :error_code => "CodigoErro",
        :error_message => "MensagemErro",
        :payment_method => "CodigoPagamento",
        :payment_method_name => "FormaPagamento",
        :installments => "NumeroParcelas",
        :status => "Status",
        :amount => "Valor",
        :cancelled_at => "DataCancelamento",
        :paid_at => "DataPagamento",
        :order_date => "DataPedido",
        :transaction_id => "TransId",
        :tid => "BraspagTid"
      })

      raise InvalidData if response[:authorization].nil?
      response
    end

    def self.status_url
      connection = Braspag::Connection.instance
      connection.braspag_url + (connection.production? ? PRODUCTION_INFO_URI : HOMOLOGATION_INFO_URI)
    end
  end
end
