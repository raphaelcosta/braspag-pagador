module BraspagPagador
  class Connection
    def get(order)
      response = self.post(:info, order)

      if (  response.size == 0 ||
            !response.fetch(:error_code, nil).nil? ||
            response.fetch(:status, nil).nil?
         )
        return ActiveMerchant::Billing::Response.new(false,
                     response.fetch(:error_message, ''),
                     response,
                     :test => homologation?)
      end

      case order.payment_method_type?
      when :billet
        self.post(:info_billet, order)
      when :credit_card
        self.post(:info_credit_card, order)
      end

      ActiveMerchant::Billing::Response.new(true,
                   'OK',
                   response,
                   :test => homologation?)
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
        if BraspagPagador::PAYMENT_METHOD.key(value).nil?
          record.errors.add attribute, "invalid payment code"
        end
      end
    end

    class InstallmentsTypeValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        if BraspagPagador::INTEREST.key(value).nil?
          record.errors.add attribute, "invalid installments type"
        end
      end
    end

    attr_accessor :id, :payment_method, :amount, :customer, :installments, :installments_type
    attr_accessor :gateway_authorization, :gateway_id, :gateway_return_code, :gateway_status, :gateway_message, :gateway_amount
    attr_accessor :gateway_capture_return_code, :gateway_capture_status, :gateway_capture_message, :gateway_capture_amount
    attr_accessor :gateway_void_return_code, :gateway_void_status, :gateway_void_message, :gateway_void_amount
    attr_accessor :authorization, :payment_method_name, :status, :gateway_cancelled_at, :gateway_paid_at
    attr_accessor :gateway_created_at, :transaction_id, :gateway_id, :billet, :credit_card

    [:purchase, :generate, :authorize, :capture, :void, :recurrency].each do |check_on|
      validates :id, :presence => { :on => check_on }
      validates :id, :length => {:minimum => 1, :maximum => 20, :on => check_on }
      validates :id, :format => { :with => /\A[0-9]+\z/, :on => check_on, :if => :payment_for_cielo? }
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
      validates :installments, :format => { :with => /1/, :on => check_on, :if => :no_interest? }
      validates :installments_type, :presence => { :on => check_on }
      validates :installments_type, :installments_type => { :on => check_on }
    end

    def no_interest?
      case installments_type
      when BraspagPagador::INTEREST[:no],
           BraspagPagador::INTEREST[:no_iata]
        true
      else
        false
      end
    end

    def payment_method_type?
      Converter.payment_method_type?(self.payment_method)
    end

    def build_customer
      self.customer = Customer.new
    end

    def build_billet
      self.billet = Billet.new
    end

    def build_credit_card
      self.credit_card = CreditCard.new
    end

    def self.to_info(connection, order)
      {
        "loja"          => connection.merchant_id,
        "numeroPedido"  => order.id.to_s
      }
    end

    def self.from_info(connection, order, params)
      response = BraspagPagador::Converter::hash_from_xml(params.body, {
        :authorization => "CodigoAutorizacao",
        :error_code => "CodigoErro",
        :error_message => "MensagemErro",
        :payment_method => "CodigoPagamento",
        :payment_method_name => "FormaPagamento",
        :installments => "NumeroParcelas",
        :status => "Status",
        :amount => "Valor",
        :cancelled_at => Proc.new { |document|
          begin
            Time.parse(document.search("DataCancelamento").first.to_s)
          rescue
            nil
          end
        },
        :paid_at => Proc.new { |document|
          begin
            Time.parse(document.search("DataPagamento").first.to_s)
          rescue
            nil
          end
        },
        :order_date => Proc.new { |document|
          begin
            Time.parse(document.search("DataPedido").first.to_s)
          rescue
            nil
          end
        },
        :transaction_id => "TransId",
        :tid => "BraspagTid"
      })

      order.authorization = response[:authorization]
      order.payment_method_name = response[:payment_method_name]
      order.payment_method = response[:payment_method]
      order.installments = response[:installments]
      order.status = response[:status]
      order.amount = BraspagPagador::Converter::string_to_decimal(response[:amount], :eua)
      order.gateway_cancelled_at = response[:cancelled_at]
      order.gateway_paid_at = response[:paid_at]
      order.gateway_created_at = response[:order_date]
      order.transaction_id = response[:transaction_id]
      order.gateway_id = response[:tid]

      response
    end

    def self.to_info_credit_card(connection, order)
      {
        "loja"          => connection.merchant_id,
        "numeroPedido"  => order.id.to_s
      }
    end

    def self.from_info_credit_card(connection, order, params)
      response = BraspagPagador::Converter::hash_from_xml(params.body, {
          :checking_number => "NumeroComprovante",
          :certified => "Autenticada",
          :autorization_number => "NumeroAutorizacao",
          :card_number => "NumeroCartao",
          :transaction_number => "NumeroTransacao",

          :avs_response => "RetornoAVS",
          :issuing => "Emissor",
          :authenticated_number => "NumeroAutenticacao"
      })

      order.build_credit_card if order.credit_card.nil?

      order.credit_card.checking_number = response[:checking_number]
      order.credit_card.avs = response[:certified]
      order.credit_card.autorization_number = response[:autorization_number]
      order.credit_card.number = response[:card_number]
      order.credit_card.transaction_number = response[:transaction_number]
      order.credit_card.avs_response = response[:avs_response]
      order.credit_card.issuing = response[:issuing]
      order.credit_card.authenticated_number = response[:authenticated_number]

      response
    end

    def self.to_info_billet(connection, order)
      {
        "loja"          => connection.merchant_id,
        "numeroPedido"  => order.id.to_s
      }
    end

    def self.from_info_billet(connection, order, params)
      response = BraspagPagador::Converter::hash_from_xml(params.body, {
          :document_number => "NumeroDocumento",
          :payer => "Sacado",
          :our_number => "NossoNumero",
          :bill_line => "LinhaDigitavel",
          :document_date => Proc.new { |document|
            begin
              Date.parse(document.search("DataDocumento").first.to_s)
            rescue
              nil
            end
          },
          :expiration_date => Proc.new { |document|
            begin
              Date.parse(document.search("DataVencimento").first.to_s)
            rescue
              nil
            end
          },
          :receiver => "Cedente",
          :bank => "Banco",
          :agency => "Agencia",
          :account => "Conta",
          :wallet => "Carteira",
          :amount => "ValorDocumento",
          :amount_invoice => "ValorPago",
          :invoice_date => Proc.new { |document|
            begin
              Date.parse(document.search("DataCredito").first.to_s)
            rescue
              nil
            end
          }
      })

      order.build_customer if order.customer.nil?
      order.customer.name = response[:payer]

      order.build_billet if order.billet.nil?
      order.billet.id = response[:our_number]
      order.billet.code = response[:bill_line]

      order.billet.created_at = response[:document_date]
      order.billet.due_date_on = response[:expiration_date]

      order.billet.receiver = response[:receiver]

      order.billet.bank = response[:bank]
      order.billet.agency = response[:agency]
      order.billet.account = response[:account]
      order.billet.wallet = response[:wallet]
      order.billet.amount = BraspagPagador::Converter::string_to_decimal(response[:amount])
      order.billet.amount_paid = BraspagPagador::Converter::string_to_decimal(response[:amount_invoice])
      order.billet.paid_at = response[:invoice_date]

      response
    end

    private
    def payment_for_cielo?
      case payment_method
      when BraspagPagador::PAYMENT_METHOD[:cielo_noauth_visa],
           BraspagPagador::PAYMENT_METHOD[:cielo_preauth_visa],
           BraspagPagador::PAYMENT_METHOD[:cielo_noauth_mastercard],
           BraspagPagador::PAYMENT_METHOD[:cielo_preauth_mastercard],
           BraspagPagador::PAYMENT_METHOD[:cielo_noauth_elo],
           BraspagPagador::PAYMENT_METHOD[:cielo_noauth_diners]
        true
      end
    end

  end
end
