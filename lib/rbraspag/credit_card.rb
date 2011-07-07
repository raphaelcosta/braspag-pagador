module Braspag
  class CreditCard

    def initialize(connection, params)
      raise InvalidConnection unless connection.is_a?(Braspag::Connection)

      @connection = connection
      @params = params
      @params[:merchant_id] = connection.merchant_id

      ok?
    end

    def ok?
      [:order_id, :customer_name, :amount, :payment_method, :holder,
        :card_number, :expiration, :security_code, :number_payments, :type].each do |param|
        raise IncompleteParams unless @params.include?(param)
      end

      raise InvalidOrderId unless (1..20).include?(@params[:order_id].to_s.size)
      raise InvalidCustomerName unless (1..100).include?(@params[:customer_name].to_s.size)
      raise InvalidAmount unless (1..10).include?(@params[:amount].to_s.size)
      raise InvalidHolder unless (1..100).include?(@params[:holder].to_s.size)
      raise InvalidExpirationDate unless (1..7).include?(@params[:expiration].to_s.size)
      raise InvalidSecurityCode unless (1..4).include?(@params[:security_code].to_s.size)
      raise InvalidNumberPayments unless (1..2).include?(@params[:number_payments].to_s.size)
      raise InvalidType unless (1..2).include?(@params[:type].to_s.size)
    end

  end
end
