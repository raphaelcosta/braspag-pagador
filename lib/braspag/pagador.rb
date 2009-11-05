module Braspag
  class Pagador < Handsoap::Service
    BASE_ACTION_URL = "https://www.pagador.com.br/webservice/pagador"

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

    def authorize(map)
      document = invoke_and_parse('Authorize') do |message|
        map.each do |key, value|
          message.add("tns:#{key}", "#{value}")
        end
      end
      convert_to_map document
    end

    private
    def configure_endpoint
      self.class.endpoint :uri => "#{@connection.base_url}/webservice/pagador.asmx",
                          :version => 2
    end

    def convert_to_map(document)
      map = {"amount" => "", "authorisationNumber" => "", "message" => "", "returnCode" => "", "status" => "", "transactionId" => ""}
      map.each_key do |key|
        document.xpath("//ns:#{key}").each do |text|
          map[key] = text.to_s
        end
      end
      map
    end

  end
end
