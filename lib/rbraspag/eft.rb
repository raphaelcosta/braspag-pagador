module Braspag
  class Eft
    PAYMENT_METHOD = {
      :bradesco => "11",
    }

    MAPPING = {
      :merchant_id => "Id_Loja",
      :order_id => "VendaId",
      :customer_name => "Nome",
      :customer_id => "Cpf",
      :amount => "Valor",
      :payment_method => "codpagamento",
      :installments => "PARCELAS",
      :has_interest => "TIPOPARCELADO"
    }

    def initialize(connection, params, crypto_strategy = nil)
      raise InvalidConnection unless connection.is_a?(Braspag::Connection)

      @connection = connection
      @params = params
      @params[:merchant_id] = connection.merchant_id
      @crypto_strategy = crypto_strategy
      
      if @params[:amount] && !@params[:amount].is_a?(BigDecimal)
        @params[:amount] = BigDecimal.new(@params[:amount].to_s)
      end
      
      ok?
    end

    def ok?
      raise IncompleteParams if @params[:order_id].nil? || @params[:amount].nil? || @params[:payment_method].nil?

      raise InvalidOrderId unless @params[:order_id].is_a?(String) || @params[:order_id].is_a?(Fixnum)
      raise InvalidOrderId unless (1..50).include?(@params[:order_id].to_s.size)

      unless @params[:customer_name].nil?
        raise InvalidCustomerName unless (1..255).include?(@params[:customer_name].to_s.size)
      end

      unless @params[:customer_id].nil?
        raise InvalidCustomerId unless (11..18).include?(@params[:customer_id].to_s.size)
      end

      unless @params[:installments].nil?
        raise InvalidInstallments unless (1..2).include?(@params[:installments].to_s.size)
        begin
          @params[:installments] = Integer(@params[:installments]) unless @params[:installments].is_a?(Integer)
        rescue Exception => e
          raise InvalidInstallments
        end
      end

      unless @params[:has_interest].nil?
        raise InvalidHasInterest unless (@params[:has_interest].is_a?(TrueClass) || @params[:has_interest].is_a?(FalseClass))
      end

      true
    end
    
    def generate
      data =  create_data_from_params

      html = "<form id=\"form_tef_#{@params[:order_id]}\" name=\"form_tef_#{@params[:order_id]}\" action=\"#{self.uri}\" method=\"post\">\n"

      if @crypto_strategy.nil?
        data.each do |key, value|
          html.concat "  <input type=\"text\" name=\"#{key}\" value=\"#{value}\" />\n"
        end
      else
        data.delete("Id_Loja")
        html.concat "  <input type=\"text\" name=\"crypt\" value=\"#{@crypto_strategy.encrypt(data)}\" />\n"
        html.concat "  <input type=\"text\" name=\"Id_Loja\" value=\"#{@params[:merchant_id]}\" />\n"
      end

      html.concat <<-EOHTML
</form>
<script type="text/javascript" charset="utf-8">
  document.forms["form_tef_#{@params[:order_id]}"].submit();
</script>
      EOHTML

      html
    end

    protected
    def create_data_from_params
      MAPPING.inject({}) do |memo, k|
        if k[0] == :payment_method
          memo[k[1]] = PAYMENT_METHOD[@params[:payment_method]]
        elsif k[0] == :amount
          memo[k[1]] = convert_decimal_to_string(@params[:amount])
        else
          memo[k[1]] = @params[k[0]] || "";
        end

        memo
      end
    end

    def convert_decimal_to_string(value)
      cents = "0#{((value - value.to_i) * 100).to_i}".slice(-2,2)
      integer = (value - (value - value.to_i)).to_i
      "#{integer},#{cents}"
    end

    def uri
      "#{@connection.base_url}/pagador/passthru.asp"
    end
  end
end