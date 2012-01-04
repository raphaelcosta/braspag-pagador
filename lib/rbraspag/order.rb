module Braspag
  class Order
    class InvalidData < Exception; end

    def self.status(order_id)
      connection = Braspag::Connection.instance

      raise InvalidOrderId unless order_id.is_a?(String) || order_id.is_a?(Fixnum)
      raise InvalidOrderId unless (1..50).include?(order_id.to_s.size)

      request = ::HTTPI::Request.new("#{connection.braspag_query_url}/GetDadosPedido")
      request.body = {:loja => connection.merchant_id, :numeroPedido => order_id.to_s}

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
  end
end
