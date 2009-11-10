module Braspag
  class Recorrente < Handsoap::Service
    BASE_ACTION_URL = "https://www.pagador.com.br/webservice/recorrente"

    def initialize(connection)
      @connection = connection
      configure_endpoint
    end

    def on_create_document(doc)
      doc.alias 'tns', BASE_ACTION_URL
    end

    def on_response_document(doc)
      doc.add_namespace 'ns', BASE_ACTION_URL
    end

    def create_creditcard_order(map)
      soap_action = "#{BASE_ACTION_URL}/CreateCreditCardOrder"
      document = invoke_and_parse('CreateCreditCardOrder', soap_action) do |message|
        map.each do |key, value|
          message.add("tns:#{key}", "#{value}")
        end
      end
      convert_to_map document
    end

    private
    def configure_endpoint
      self.class.endpoint :uri => "#{@connection.base_url}/webservice/recorrente.asmx",
                          :version => 2
    end

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
