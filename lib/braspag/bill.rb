module Braspag
  class Bill
    class InvalidConnection < Exception ; end
    class InvalidOrderId < Exception ; end
    class InvalidAmount < Exception ; end
    class InvalidPaymentMethod < Exception ; end

    def initialize(connection, hash = {})
      @connection = connection
      @orderId = hash[:orderId]
      @amount = hash[:amount]
      @paymentMethod = hash[:paymentMethod]

      raise InvalidConnection unless connection.instance_of?(Braspag::Connection)
      raise InvalidOrderId unless (@orderId.instance_of?(String) || @orderId.instance_of?(Fixnum))
      raise InvalidAmount unless (@amount.instance_of?(String) || @amount.instance_of?(Fixnum))
      raise InvalidPaymentMethod unless (@paymentMethod.instance_of?(String) || @paymentMethod.instance_of?(Fixnum))

    end

    def generate
      {

        :url => "url_do_boleto",
        :status => "0",
        :returnCode => "0",
        :amount => "3",
        :number => "125",
        :expirationDate => "2001"

      }
    end

    protected
    def uri
      "#{@connection.base_url}/webservices/pagador/Boleto.asmx/CreateBoleto"
    end
  end
end
