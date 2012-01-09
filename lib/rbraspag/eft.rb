module Braspag
  class Eft < PaymentMethod

    PAYMENT_METHODS = {
      :bradesco => 11,
      :itau => 12,
      :banco_do_brasil => 15,
      :banco_real => 16,
      :banrisul => 30,
      :unibanco => 31
    }

    MAPPING = {
      :merchant_id => "Id_Loja",
      :order_id => "VENDAID",
      :customer_name => "nome",
      :customer_id => "CPF",
      :amount => "VALOR",
      :payment_method => "CODPAGAMENTO",
      :installments => "PARCELAS",
      :has_interest => "TIPOPARCELADO"
    }

    ACTION_URI = "/pagador/passthru.asp"

    def self.generate(params, crypto_strategy = nil)
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

    def self.check_params(params)
      super

      if params[:installments]
        raise InvalidInstallments if params[:installments].to_i < 1 || params[:installments].to_i > 99
      end

      if params[:has_interest]
        raise InvalidHasInterest unless (params[:has_interest].is_a?(TrueClass) || params[:has_interest].is_a?(FalseClass))
      end
    end

    def self.action_url
      Braspag::Connection.instance.braspag_url + ACTION_URI
    end
  end
end
