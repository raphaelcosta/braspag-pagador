module Braspag
  class Connection
    def self.get(order)
      return ::Response
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
      
      self.get_billet(order)
      self.get_credit_card(order)
      response
    end
    
    private
    def self.get_billet(order)

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
    
    def self.get_credit_card(order)
      data = {:loja => self.merchant_id, :numeroPedido => order.id.to_s}
      response = Braspag::Poster.new(self, self.info_url).do_post(:info_credit_card, data)

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
  
  class Order
    include ::ActiveAttr::Model
    
    attr_accessor :id, :payment_method, :amount, :customer, :installments, :installments_type
    
    [:purchase, :generate, :authorize, :capture, :void, :recurrency].each do |check_on|
      validates :id, :presence => { :on => check_on }
      validates :id, :length => {:minimum => 1, :maximum => 50, :on => check_on }
      #VALIDATES ID FOR PAYMENT_METHOD IF HAS
    end
    
    [:purchase, :generate, :authorize, :recurrency].each do |check_on|
      validates :payment_method, :presence => { :on => check_on }
      validates :amount, :presence => { :on => check_on }
      validates :amount, :numericality => {:greater_than => 0, :on => check_on}
      
      validates :customer, :presence => { :on => check_on }
      #VALIDATES CUSTOMER
    end
    
    [:purchase, :authorize, :recurrency].each do |check_on|
      validates :installments, :presence => { :on => check_on }
      validates :installments, :numericality => {:only_integer => true, :greater_than => 0, :less_than => 100, :on => check_on}
      validates :installments_type, :presence => { :on => check_on }
      
      #VALIDATES INSTALLMENTS_TYPE
      #VALIDATES PAYMENT_METHOD
      #numberPayments ￼ ￼ ￼ ￼ Número de parcelas
      # (para pagamento à vista o valor
      # deve ser 01)
    end
    
    def which_method_for?(payment)
      #TODO ADD FALLBACK FOR MAPPING IN CONNECTION
      case payment.class
      when Braspag::Billet
        :generate_billet
      when Braspag::EFT
        :generate_eft
      end
    end
  end
end
