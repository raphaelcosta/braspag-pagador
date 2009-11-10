module Braspag
  class Cryptography < Handsoap::Service
    include Braspag::Service

    def encrypt(map)
      soap_action = "#{base_action_url}/EncryptRequest"
      invoke_and_parse('EncryptRequest', soap_action) do |message|
        message.add("tns:request") do |sub_message|
          map.each do |key, value|
            sub_message.add("tns:string", "#{key}=#{value}")
          end
        end
      end.to_s
    end

    def decrypt(encripted_text)
      soap_action = "#{base_action_url}/DecryptRequest"
      document = invoke_and_parse('DecryptRequest', soap_action) do |message|
        message.add("tns:cryptString", encripted_text)
      end
      convert_request_to_map document
    end

    def base_action_url
      "https://www.pagador.com.br/webservice/BraspagGeneralService"
    end

    def uri
      "#{@connection.base_url}/BraspagGeneralService/BraspagGeneralService.asmx"
    end

    private
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
