module Braspag
  class Connection
    def self.get(order)
      #check if order.is valid for get
      return ::Response
      
      response = Braspag::Poster.new(self, self.url_for(:info)).do_post(:info, {
        :loja => self.merchant_id, :numeroPedido => order.id.to_s
      })
      
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

      # raise InvalidData if response[:authorization].nil?
      
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
    
    class AssociationValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless value.respond_to?(:valid?) && value.try(:valid?, self.options[:on])
          record.errors.add attribute, "invalid data"
        end
      end
    end
    
    class PaymentMethodValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if Braspag::PAYMENT_METHOD.key(value).nil?
          record.errors.add attribute, "invalid payment code"
        end
      end
    end
    
    attr_accessor :id, :payment_method, :amount, :customer, :installments, :installments_type
    
    [:purchase, :generate, :authorize, :capture, :void, :recurrency].each do |check_on|
      validates :id, :presence => { :on => check_on }
      validates :id, :length => {:minimum => 1, :maximum => 20, :on => check_on }
      validates :id, :format => { :with => /^[0-9]+$/, :on => check_on, :if => :payment_for_cielo? }
    end
    
    [:purchase, :generate, :authorize, :recurrency].each do |check_on|
      validates :payment_method, :presence => { :on => check_on }
      validates :payment_method, :payment_method => { :on => check_on }

      validates :amount, :presence => { :on => check_on }
      validates :amount, :numericality => {:greater_than => 0, :on => check_on}
      
      validates :customer, :presence => { :on => check_on }
      validates :customer, :association => { :on => check_on }
    end
    
    [:purchase, :authorize, :recurrency].each do |check_on|
      validates :installments, :presence => { :on => check_on }
      validates :installments, :numericality => {:only_integer => true, :greater_than => 0, :less_than => 100, :on => check_on}
      validates :installments_type, :presence => { :on => check_on }
      
      #VALIDATES INSTALLMENTS_TYPE
      #numberPayments ￼ ￼ ￼ ￼ Número de parcelas
      # (para pagamento à vista o valor
      # deve ser 01)
    end
    
    def which_method_for?(payment)
      #TODO ADD FALLBACK FOR MAPPING
      case payment.class
      when Braspag::Billet
        :generate_billet
      when Braspag::EFT
        :generate_eft
      end
    end
    
    private
    def payment_for_cielo?
      case payment_method
      when Braspag::PAYMENT_METHOD[:cielo_noauth_visa],
           Braspag::PAYMENT_METHOD[:cielo_preauth_visa],
           Braspag::PAYMENT_METHOD[:cielo_noauth_mastercard],
           Braspag::PAYMENT_METHOD[:cielo_preauth_mastercard],
           Braspag::PAYMENT_METHOD[:cielo_noauth_elo],
           Braspag::PAYMENT_METHOD[:cielo_noauth_diners]
        true
      end
    end
  end
end
