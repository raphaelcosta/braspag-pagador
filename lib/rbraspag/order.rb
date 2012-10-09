module Braspag
  class Order
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
