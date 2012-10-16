module Braspag
  class Order
    
    STATUS_PAYMENT = {
      :starting => "1",
      :close => "2",
      :paid => "3",
      :cancelled => "4"
    }
    

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
  end
end
