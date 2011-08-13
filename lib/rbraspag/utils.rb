module Braspag
  class Utils
    def self.convert_decimal_to_string(value)
      cents = "0#{((value - value.to_i) * 100).to_i}".slice(-2,2)
      integer = (value - (value - value.to_i)).to_i
      "#{integer}#{cents}"
    end

    def self.convert_to_map(document, map = {})
      document = Nokogiri::XML(document)

      map.each do |keyForMap , keyValue|
        if keyValue.is_a?(String) || keyValue.nil?
          keyValue = keyForMap if keyValue.nil?

          value = document.search(keyValue).first
          if !value.nil?
            value = value.content.to_s
            map[keyForMap] = value unless value == ""
            map[keyForMap] = nil if value == ""
          else
            map[keyForMap] = nil
          end

        elsif keyValue.is_a?(Proc)
          map[keyForMap] = keyValue.call(document)
        end

        map[keyForMap]
      end

      map
    end
  end
end
