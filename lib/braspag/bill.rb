module Braspag
  class Bill
    class InvalidConnection < Exception ; end
    class InvalidOrderId < Exception ; end
    class InvalidAmount < Exception ; end
    class InvalidPaymentMethod < Exception ; end
    class InvalidCustomerName < Exception ; end

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
      convert_to_map (HTTPI.post request).body
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
        :status => nil
      }


      map.each do |key , value|
        map[key] = document.search(key.to_s).first.content.to_s if value.nil?
        map[key] = document.search(value).first.content.to_s if value.instance_of?(String)
      end

      map
    end

  end
end
