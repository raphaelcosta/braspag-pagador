module Braspag
  class Bill

    class InvalidConnection < Exception ; end
    class IncompleteParams < Exception ; end
    class InvalidOrderId < Exception ; end
    class InvalidCustomerName < Exception ; end
    class InvalidCustomerId < Exception ; end
    class InvalidBoletoNumber < Exception ; end
    class InvalidInstructions < Exception ; end
    class InvalidExpirationDate < Exception ; end
    class InvalidStringFormat < Exception ; end
    class InvalidPost < Exception ; end
    class InvalidPaymentMethod < Exception ; end
    class InvalidAmount < Exception ; end
    class UnknownError < Exception ; end

    def initialize(connection, params)

      raise InvalidConnection unless connection.is_a?(Braspag::Connection)

      params[:merchantId] = connection.merchant_id

      raise IncompleteParams if params[:orderId].nil? || params[:amount].nil? || params[:paymentMethod].nil?

      raise InvalidOrderId unless params[:orderId].is_a?(String) || params[:orderId].is_a?(Fixnum)
      raise InvalidOrderId unless (1..50).include?(params[:orderId].to_s.size)

      unless params[:customerName].nil?
        raise InvalidCustomerName unless (1..255).include?(params[:customerName].to_s.size)
      end

      unless params[:customerIdNumber].nil?
        raise InvalidCustomerId unless (11..18).include?(params[:customerIdNumber].to_s.size)
      end

      unless params[:boletoNumber].nil?
        raise InvalidBoletoNumber unless (1..255).include?(params[:boletoNumber].to_s.size)
      end

      unless params[:instructions].nil?
        raise InvalidInstructions unless (1..512).include?(params[:instructions].to_s.size)
      end

      unless params[:expirationDate].nil?
        raise InvalidExpirationDate unless params[:expirationDate].to_s.size == 8
      end

      @connection = connection
      @params = params
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

