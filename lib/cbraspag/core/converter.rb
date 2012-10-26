module Braspag
  class Converter
    def self.decimal_to_string(value)
      #TODO: CHANGE ANOTHER FOR CONVERSION
      ("%.2f" % value.to_f).gsub('.', ',')
    end
    
    def self.string_to_decimal(value)
      BigDecimal.new(value.to_s.gsub(".","").gsub(",","."))
    end

    def self.hash_from_xml(document, map = {})
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
    
    def self.payment_method_name?(code)
      Braspag::PAYMENT_METHOD.key(code.to_s.to_i)
    end

    def self.payment_method_type?(code)
      key = Braspag::PAYMENT_METHOD.key(code.to_s.to_i)
      return nil if key.nil?
      if key.match(/billet_/)
        :billet
      elsif key.match(/eft_/)
        :eft
      else
        :credit_card
      end
    end
    
    def self.status_name?(code)
      Braspag::STATUS_PAYMENT.key(code.to_s.to_i)
    end
  end
end
