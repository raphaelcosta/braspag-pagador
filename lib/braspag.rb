require 'rubygems'
require 'handsoap'
require 'braspag/cryptography'
require 'braspag/connection'
require 'braspag/pagador'
require 'braspag/recorrente'

module Braspag
  class Production
    BASE_URL = 'https://www.pagador.com.br'
  end

  class Test
    BASE_URL = 'https://homologacao.pagador.com.br'
  end

  class Development
    BASE_URL = 'https://homologacao.pagador.com.br'
  end
end

module Handsoap
  class Service

    private
    def invoke_and_parse(method_name, &block)
      response = invoke("tns:#{method_name}") do |message|
        message.add("tns:merchantId", @connection.merchant_id)
        block.call(message)
      end
      response.document.xpath("//ns:#{method_name}Result").first
    end
  end
end
