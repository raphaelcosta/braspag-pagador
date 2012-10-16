module Braspag
  class Utils
    def self.convert_decimal_to_string(value)
      ("%.2f" % value.to_f).gsub('.', ',')
    end

    def self.convert_to_map(document, map = {})
      document = Nokogiri::XML(document)

      map.each do |key, value|
        if value.is_a?(String) || value.nil?
          value = key if value.nil?

          new_value = document.search(value).first

          if new_value.nil?
            map[key] = nil
          else
            new_value = new_value.content.to_s
            map[key] = new_value unless new_value == ""
            map[key] = nil if new_value == ""
          end

        elsif value.is_a?(Proc)
          map[key] = value.call(document)
        end
      end

      map
    end
  end
end
