module Braspag
  class CreditCard

    def initialize(connection, params)
      raise InvalidConnection unless connection.is_a?(Braspag::Connection)

      @connection = connection
      @params = params
      @params[:merchant_id] = connection.merchant_id

      ok?
      # verifica se os dados são consistentes
    end

    def ok?
      p = [:order_id, :customer_name, :amount, :payment_method, :holder, :card_number, :expiration, :security_code, :number_payments, :type]

      p.each {|param| raise IncompleteParams unless @params.include?(param)}

=begin

        :customer_name => "W" * 21,
         :amount => "100.00",
         :payment_method => 20,
         :holder => "Joao Maria Souza",
         :card_number => "9" * 10,
         :expiration => "10/12",
         :security_code => "123",
         :number_payments => 1,
         :type => 0
=end

    end

  end
end
