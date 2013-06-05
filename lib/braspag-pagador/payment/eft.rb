module BraspagPagador
  class Connection
    def generate_eft(order, eft)

      params = {
        Id_Loja:      self.merchant_id,
        VALOR:        BraspagPagador::Converter::decimal_to_string(order.amount),
        CODPAGAMENTO: order.payment_method,
        VENDAID:      order.id,
        NOME:         order.customer.name
      }

      html = "<form id='form_tef_#{order.id}' name='form_tef_#{order.id}' action='#{self.url_for(:generate_eft)}' method='post'>"


      begin
        unless eft.crypto.respond_to?(:encrypt)
          params.each do |key, value|
            html << "<input type='text' name='#{key}' value='#{value}' />"
          end
        else
          params.delete("Id_Loja")
          html << "<input type='text' name='Id_Loja' value='#{self.merchant_id}' />"
          html << "<input type='text' name='crypt' value='#{eft.crypto.encrypt(self, params)}' />"
        end

        html << "</form><script type='text/javascript' charset='utf-8'>document.forms['form_tef_#{order.id}'].submit();</script>"

        eft.code = html
        status = true
        message = 'OK'
      rescue Exception => e
        status = false
        message = e.message
      end

      ActiveMerchant::Billing::Response.new(status,
       message,
       {},
       :test => homologation?)
    end
  end

  class EFT
    include ::ActiveAttr::Model

    class CryptoValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless (
          value.kind_of?(BraspagPagador::Crypto::NoCrypto) ||
          value.respond_to?(:encrypt)
          )
          record.errors.add attribute, "invalid crypto"
        end
      end
    end

    attr_accessor :crypto, :code

    validates :crypto, :presence => { :on => :generate }
    validates :crypto, :crypto => { :on => :generate }

  end

end
