module Braspag
  class Recorrente < Handsoap::Service
    include Braspag::Service

    def create_creditcard_order(map)
      soap_action = "#{base_action_url}/CreateCreditCardOrder"
      document = invoke_and_parse('CreateCreditCardOrder', soap_action) do |message|
        map.each do |key, value|
          message.add("tns:#{key}", "#{value}")
        end
      end
      convert_to_map document
    end

    def base_action_url
      "https://www.pagador.com.br/webservice/recorrente"
    end

    def uri
      "#{@connection.base_url}/webservice/recorrente.asmx"
    end

    private
    def convert_to_map(document)
      map = {"code" => "", "description" => ""}
      map.each_key do |key|
        document.xpath("//ns:#{key}").each do |text|
          map[key] = text.to_s
        end
      end
      map
    end

  end
end
