module Braspag
  class Order

    class InvalidData < Exception; end

    def self.status(connection, order_id)
      raise InvalidConnection unless connection.is_a?(Braspag::Connection)

      raise InvalidOrderId unless order_id.is_a?(String) || order_id.is_a?(Fixnum)
      raise InvalidOrderId unless (1..50).include?(order_id.to_s.size)

      request = ::HTTPI::Request.new("#{connection.base_url}/pagador/webservice/pedido.asmx/GetDadosPedido")
      request.body = {:loja => connection.merchant_id, :numeroPedido => order_id.to_s}

      response = ::HTTPI.post(request)

      response = convert_to_map response.body

      raise InvalidData if response[:authorization].nil?
      response

    end

    def self.convert_to_map(document)
      document = Nokogiri::XML(document)

      map = {
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
      }

      map.each do |keyForMap , keyValue|
        if keyValue.is_a?(String) || keyValue.nil?
          keyValue = keyForMap if keyValue.nil?

          value = document.search(keyValue).first
          if !value.nil?
            value = value.content.to_s
            map[keyForMap] = value unless value == ""
            map[keyForMap] = nil if value == ""
          else
            map[keyForMap] = nil
          end

        elsif keyValue.is_a?(Proc)
          map[keyForMap] = keyValue.call
        end

        map[keyForMap]
      end

      map
    end

  end
end
