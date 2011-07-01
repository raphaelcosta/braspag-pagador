module Braspag
  class Bill

    MAPPING = {
      :merchant_id => "merchantId",
      :order_id => "orderId",
      :customer_name => "customerName",
      :customer_id => "customerIdNumber",
      :amount => "amount",
      :payment_method => "paymentMethod",
      :number => "boletoNumber",
      :instructions => "instructions",
      :expiration_date => "expirationDate"
    }

    def initialize(connection, params)
      raise InvalidConnection unless connection.is_a?(Braspag::Connection)

      @connection = connection
      @params = params
      @params[:merchant_id] = connection.merchant_id

      if @params[:expiration_date].is_a?(Date)
        @params[:expiration_date] = @params[:expiration_date].strftime("%d/%m/%y")
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

      unless @params[:number].nil?
        raise InvalidNumber unless (1..255).include?(@params[:number].to_s.size)
      end

      unless @params[:instructions].nil?
        raise InvalidInstructions unless (1..512).include?(@params[:instructions].to_s.size)
      end

      unless @params[:expiration_date].nil?
        raise InvalidExpirationDate unless @params[:expiration_date].to_s.size == 8
      end
      
      true
    end

    def generate
      data = {}
      @params.each {|name, value|
        if MAPPING[name].nil?
          data[name] = value
        else
          data[MAPPING[name]] = value
        end
      }

      request = ::HTTPI::Request.new uri
      request.body = data

      response = ::HTTPI.post request
      response = convert_to_map response.body

      raise InvalidAmount if response[:message] == "Invalid purchase amount"
      raise InvalidMerchantId if response[:message] == "Invalid merchantId"
      raise InvalidPaymentMethod if response[:message] == "Invalid payment method"
      raise InvalidStringFormat if response[:message] == "Input string was not in a correct format."
      raise UnknownError if response[:status].nil?

      response
    end

    protected

    def uri
      "#{@connection.base_url}/webservices/pagador/Boleto.asmx/CreateBoleto"
    end

    def convert_to_map(document)
      document = Nokogiri::XML(document)

      map = {
        :url => nil,\
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

