module Braspag
  class Buyer < Handsoap::Service
    include Braspag::Service

    def buy!(map)
      document = invoke_and_parse('Authorize', "#{base_action_url}/Authorize") do |message|
        map.each do |key, value|
          message.add("tns:#{key}", "#{value}")
        end
      end
      convert_to_map document
    end

    def base_action_url
      "https://www.pagador.com.br/webservice/pagador"
    end

    def uri
      "#{@connection.base_url}/webservices/pagador/Pagador.asmx"
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
