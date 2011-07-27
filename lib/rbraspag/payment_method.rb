module Braspag
  class PaymentMethod
    def self.payment_method_from_id(code)
      self::PAYMENT_METHODS.invert.values_at(code).first
    end
  end
end
