module Braspag
  class Connection

    MAPPING_EFT = {
      :merchant_id => "Id_Loja",
      :order_id => "VENDAID",
      :customer_name => "nome",
      :customer_id => "CPF",
      :amount => "VALOR",
      :payment_method => "CODPAGAMENTO",
      :installments => "PARCELAS",
      :has_interest => "TIPOPARCELADO"
    }


    def self.generate_eft(order, eft)
      
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

      html = "<form id=\"form_tef_#{params[:order_id]}\" name=\"form_tef_#{params[:order_id]}\" action=\"#{self.action_url}\" method=\"post\">"

      if crypto_strategy.nil?
        data.each do |key, value|
          html << "<input type=\"text\" name=\"#{key}\" value=\"#{value}\" />"
        end
      else
        data.delete("Id_Loja")
        html << "<input type=\"text\" name=\"Id_Loja\" value=\"#{params[:merchant_id]}\" />"
        html << "<input type=\"text\" name=\"crypt\" value=\"#{crypto_strategy.encrypt(data)}\" />"
      end

      html << "</form><script type=\"text/javascript\" charset=\"utf-8\">document.forms[\"form_tef_#{params[:order_id]}\"].submit();</script>"

      html
    end

    def self.normalize_params(params)
      params = super

      params[:installments] = params[:installments].to_i unless params[:installments].nil?
      params[:installments] ||= 1

      params[:has_interest] = params[:has_interest] == true ? "1" : "0"

      params
    end

  end
  
  class EFT
    include ::ActiveAttr::Model
    
    class CryptoValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        unless (
          value.kind_of?(Braspag::Crypto::Webservice) ||
          value.kind_of?(Braspag::Crypto::NoCrypto) ||
          value.kind_of?(Braspag::Crypto::JarWebservice)
        )
          record.errors.add attribute, "invalid crypto"
        end
      end
    end

    attr_accessor :crypto
    
    validates :crypto, :presence => { :on => :generate }
    validates :crypto, :crypto => { :on => :generate }

  end
  
end
