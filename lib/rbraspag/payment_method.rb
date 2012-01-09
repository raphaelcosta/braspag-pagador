module Braspag
  class PaymentMethod
    def self.payment_method_from_id(code)
      self::PAYMENT_METHODS.invert.values_at(code).first
    end

    def self.normalize_params(params)
      if params[:amount] && !params[:amount].is_a?(BigDecimal)
        params[:amount] = BigDecimal.new(params[:amount].to_s)
      end

      params
    end

    def self.check_params(params)
      [:order_id, :amount, :payment_method].each do |param|
        raise IncompleteParams if params[param].nil?
      end

      raise InvalidOrderId unless self.valid_order_id?(params[:order_id])

      if params[:customer_name]
        raise InvalidCustomerName unless (1..255).include?(params[:customer_name].to_s.size)
      end

      if params[:customer_id]
        raise InvalidCustomerId unless (11..18).include?(params[:customer_id].to_s.size)
      end

      unless params[:payment_method].is_a?(Symbol) && self::PAYMENT_METHODS[params[:payment_method]]
        raise InvalidPaymentMethod
      end
    end

    def self.valid_order_id?(order_id)
      (order_id.is_a?(String) || order_id.is_a?(Fixnum)) && (1..50).include?(order_id.to_s.size)
    end
  end
end
