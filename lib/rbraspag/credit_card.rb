module Braspag
  class CreditCard

    MAPPING = {
      :merchant_id => "merchantId",
      :order_id => "orderId",
      :customer_name => "customerName",
      :amount => "amount",
      :payment_method => "paymentMethod",
      :holder => "holder",
      :card_number => "cardNumber",
      :expiration => "expiration",
      :security_code => "securityCode",
      :number_payments => "numberPayments",
      :type => "typePayment",
    }

    def initialize(connection)
      raise InvalidConnection unless connection.is_a?(Braspag::Connection)
      @connection = connection
      @merchant_id = connection.merchant_id 
    end


    def uri_authorize
      "#{@connection.base_url}/webservices/pagador/Pagador.asmx/Authorize"
    end

    def uri_capture
      "#{@connection.base_url}/webservices/pagador/Pagador.asmx/Capture"
    end



    def authorize params

        [:order_id, :customer_name, :amount, :payment_method, :holder,
          :card_number, :expiration, :security_code, :number_payments, :type].each do |param|
            raise IncompleteParams unless params.include?(param)
          end

        raise InvalidOrderId unless (1..20).include?(params[:order_id].to_s.size)
        raise InvalidCustomerName unless (1..100).include?(params[:customer_name].to_s.size)
        raise InvalidAmount unless (1..10).include?(params[:amount].to_s.size)
        raise InvalidHolder unless (1..100).include?(params[:holder].to_s.size)
        raise InvalidExpirationDate unless (1..7).include?(params[:expiration].to_s.size)
        raise InvalidSecurityCode unless (1..4).include?(params[:security_code].to_s.size)
        raise InvalidNumberPayments unless (1..2).include?(params[:number_payments].to_s.size)
        raise InvalidType unless (1..2).include?(params[:type].to_s.size)


      data =  MAPPING.inject({}) do |memo, k|
        if k[0] == :amount
          memo[k[1]] = Utils.convert_decimal_to_string(params[:amount])
        else
          memo[k[1]] = params[k[0]] || "";
        end
        
        memo
      end
      
      request = ::HTTPI::Request.new uri_authorize
      request.body = data
      response = ::HTTPI.post request
      response = convert_to_map response.body
      
    end

    def capture order_id
      raise InvalidOrderId unless (1..20).include?(order_id.to_s.size)
      
      data = {MAPPING[:order_id] => order_id, "merchantId" => @merchant_id }
      request = ::HTTPI::Request.new uri_capture

      request.body = data
      response = ::HTTPI.post request
      
#      require "ruby-debug"
#      debugger

      response = convert_to_map response.body

    end


    def convert_to_map(document)
      document = Nokogiri::XML(document)

      map = {
        :amount => nil,
        :number => "authorisationNumber",
        :message => 'message',
        :return_code => 'returnCode',
        :status => 'status',
        :return_code => "returnCode"
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
