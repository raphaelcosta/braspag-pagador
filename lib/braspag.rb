require 'handsoap'
require 'braspag/service'
require 'braspag/cryptography'
require 'braspag/connection'
require 'braspag/gateway'
require 'braspag/recorrente'

module Braspag
  class Production
    BASE_URL = 'https://www.pagador.com.br'
  end

  class Test
    BASE_URL = 'https://homologacao.pagador.com.br'
  end
end

module Handsoap
  class Service
    private
    def invoke_and_parse(method_name, soap_action, &block)
      response = invoke("tns:#{method_name}", soap_action) do |message|
        message.add("tns:merchantId", @connection.merchant_id)
        block.call(message)
      end
      response.document.xpath("//ns:#{method_name}Result").first
    end
  end
end
