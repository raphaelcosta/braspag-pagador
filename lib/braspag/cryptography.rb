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

    def encrypt_request(map)
      invoke_and_parse('Encrypt') do |message|
        message.add("tns:request") do |sub_message|
          map.each do |key, value|
            sub_message.add("tns:#{key}", value)
          end
        end
      end
    end

    def decrypt_request!(encripted_text)
      invoke_and_parse('Decrypt') do |message|
        message.add("tns:cryptString", encripted_text)
        message.add("tns:customFields") do |sub_message|
          sub_message.add('aaaaa')
        end
      end
    end

    private

    def invoke_and_parse(method_name, &block)
      response = invoke("tns:#{method_name}Request") do |message|
        message.add("tns:merchantId", @connection.merchant_id)
        block.call(message)
      end
      response.document.xpath("//ns:#{method_name}RequestResult").first.to_s
    end

    def configure_endpoint
      self.class.endpoint :uri => "#{@connection.base_url}/BraspagGeneralService/BraspagGeneralService.asmx",
                          :version => 2
    end
  end
end
