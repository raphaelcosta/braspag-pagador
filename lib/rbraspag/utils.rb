module Braspag
  class Utils
    def self.convert_decimal_to_string(value)
      cents = "0#{((value - value.to_i) * 100).to_i}".slice(-2,2)
      integer = (value - (value - value.to_i)).to_i
      "#{integer},#{cents}"
    end
  end
end
