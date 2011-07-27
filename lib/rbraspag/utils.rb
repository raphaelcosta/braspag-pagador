module Braspag

  class Utils
    def self.convert_decimal_to_string(value)
      cents = "0#{((value - value.to_i) * 100).to_i}".slice(-2,2)
      integer = (value - (value - value.to_i)).to_i
      "#{integer},#{cents}"
    end

    def self.payment_method_from_id(class_name, code)
      all_values = eval("Braspag::#{class_name}::PAYMENT_METHODS")
      all_values.invert.values_at(code).first
    end
  end
end