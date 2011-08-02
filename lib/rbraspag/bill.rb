require "bigdecimal"

module Braspag
  class Bill < PaymentMethod
    
    PAYMENT_METHODS = {
      :bradesco => "06",
      :cef => "07",
      :hsbc => "08",
      :bb => "09",
      :real => "10",
      :citibank => "13",
      :itau => "14",
      :unibanco => "26"
    }

    MAPPING = {
      :merchant_id => "merchantId",
      :order_id => "orderId",
      :customer_name => "customerName",
      :customer_id => "customerIdNumber",
      :amount => "amount",
      :payment_method => "paymentMethod",
      :number => "boletoNumber",
      :instructions => "instructions",
      :expiration_date => "expirationDate",
      :emails => "emails"
    }

    def initialize(params)
      @connection = Braspag::Connection.instance
      @params = params
      @params[:merchant_id] = @connection.merchant_id

      if @params[:expiration_date].is_a?(Date)
        @params[:expiration_date] = @params[:expiration_date].strftime("%d/%m/%y")
      end

      if @params[:amount] && !@params[:amount].is_a?(BigDecimal)
        @params[:amount] = BigDecimal.new(@params[:amount].to_s)
      end

      ok?
    end

    def [](key)
      @params[key]
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

      unless @params[:number].nil?
        raise InvalidNumber unless (1..255).include?(@params[:number].to_s.size)
      end

      unless @params[:instructions].nil?
        raise InvalidInstructions unless (1..512).include?(@params[:instructions].to_s.size)
      end

      unless @params[:expiration_date].nil?
        date_regexp = /(0[1-9]|1[0-9]|2[0-9]|3[01])\/(0[1-9]|1[012])\/\d\d/
        raise InvalidExpirationDate unless @params[:expiration_date].to_s =~ date_regexp
      end

      unless @params[:payment_method].is_a?(Symbol) && PAYMENT_METHODS[@params[:payment_method]]
        raise InvalidPaymentMethod
      end

      true
    end

    def generate
      data =  MAPPING.inject({}) do |memo, k|
        if k[0] == :payment_method
          memo[k[1]] = PAYMENT_METHODS[@params[:payment_method]]
        elsif k[0] == :amount
          memo[k[1]] = Utils.convert_decimal_to_string(@params[:amount])
        else
          memo[k[1]] = @params[k[0]] || "";
        end
        
        memo
      end

      request = ::HTTPI::Request.new uri
      request.body = data

      response = ::HTTPI.post request
      response = convert_to_map response.body

      raise InvalidAmount if response[:message] == "Invalid purchase amount"
      raise InvalidMerchantId if response[:message] == "Invalid merchantId"
      raise InvalidPaymentMethod if response[:message] == "Invalid payment method"
      raise InvalidStringFormat if response[:message] == "Input string was not in a correct format."
      raise UnknownError if response[:status].nil?

      response[:amount] = BigDecimal.new(response[:amount])

      response
    end

    protected
  
    def uri
      "#{@connection.braspag_url}/webservices/pagador/Boleto.asmx/CreateBoleto"
    end

    def convert_to_map(document)
      document = Nokogiri::XML(document)

      map = {
        :url => nil,
        :amount => nil,
        :number => "boletoNumber",
        :expiration_date => Proc.new {
          begin
            Date.parse(document.search("expirationDate").first.to_s)
          rescue
            nil
          end
        },
        :return_code => "returnCode",
        :status => nil,
        :message => nil
      }

      map.each do |keyForMap , keyValue|
        if keyValue.is_a?(String) || keyValue.nil?
          keyValue = keyForMap if keyValue.nil?

          value = document.search(keyValue).first
          if !value.nil?
            value = value.content.to_s
            map[keyForMap] = value unless value == ""
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
