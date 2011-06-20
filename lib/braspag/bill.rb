module Braspag
  class Bill
    class InvalidOrderId < Exception ; end
    class InvalidAmount < Exception ; end
    class InvalidPaymentMethod < Exception ; end
    class InvalidStringFormat < Exception ; end
    class InvalidPost < Exception ; end

    def initialize(connection, hash = {})
      @connection = connection
      raise InvalidConnection unless connection.instance_of?(Braspag::Connection)

      @params = hash
      @params[:merchantId] = @connection.merchant_id

      raise InvalidOrderId unless (@params[:orderId].instance_of?(String) || @params[:orderId].instance_of?(Fixnum))
      raise InvalidAmount unless (@params[:amount].instance_of?(String) || @params[:amount].instance_of?(Fixnum))
      raise InvalidPaymentMethod unless (@params[:paymentMethod].instance_of?(String) || @params[:paymentMethod].instance_of?(Fixnum))

    end

    def generate
      request = HTTPI::Request.new uri
      request.body = {
        :merchantId => @params[:merchantId],
        :orderId => @params[:orderId],
        :amount => @params[:amount],
        :paymentMethod => @params[:paymentMethod],
        :customerName => @params[:customerName],
        :customerIdNumber => @params[:customerIdNumber],
        :boletoNumber => @params[:boletoNumber],
        :instructions => @params[:instructions],
        :expirationDate => @params[:expirationDate],
        :emails => @params[:emails]
      }

      response = HTTPI.post request
      response = convert_to_map response.body
      
      raise InvalidAmount if response[:message] == "Invalid purchase amount"
      raise InvalidMerchantId if response[:message] == "Invalid merchantId"
      raise InvalidPaymentMethod if response[:message] == "Invalid payment method"
      raise InvalidStringFormat if response[:message] == "Input string was not in a correct format."
      raise InvalidPost if response[:status].nil?

      response
    end

    protected
    def uri
      "#{@connection.base_url}/webservices/pagador/Boleto.asmx/CreateBoleto"
    end

    def convert_to_map(document)
      document = Nokogiri::XML(document)

      map = {
        :url => nil,
        :amount => nil,
        :number => "boletoNumber",
        :expirationDate => nil,
        :returnCode => nil,
        :status => nil,
        :message => nil
      }


      map.each do |keyForMap , keyValue|
        keyValue = keyForMap if keyValue.nil?

        value = document.search(keyValue).first
        if !value.nil?
          value = value.content.to_s
          map[keyForMap] = value unless value == ""
        end
        map[keyForMap]
      end

      map
    end

  end
end
