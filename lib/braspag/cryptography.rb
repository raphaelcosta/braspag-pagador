module Braspag
  class Cryptography < Handsoap::Service
    BASE_ACTION_URL = "https://www.pagador.com.br/webservice/BraspagGeneralService"

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

    def encrypt(map)
      invoke_and_parse('EncryptRequest') do |message|
        message.add("tns:request") do |sub_message|
          map.each do |key, value|
            sub_message.add("tns:string", "#{key}=#{value}")
          end
        end
      end.to_s
    end

    def decrypt(encripted_text)
      document = invoke_and_parse('DecryptRequest') do |message|
        message.add("tns:cryptString", encripted_text)
      end
      convert_request_to_map document
    end

    private
    def configure_endpoint
      self.class.endpoint :uri => "#{@connection.base_url}/BraspagGeneralService/BraspagGeneralService.asmx",
                          :version => 2
    end

    def convert_request_to_map(document)
      map = {}
      document.xpath("//ns:string").each do |text|
        values = text.to_s.split("=")
        map[values[0].downcase.to_sym] = values[1]
      end
      map
    end
  end
end
