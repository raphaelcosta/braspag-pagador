require 'rubygems'
require 'handsoap'
require 'braspag/payment_types'
require 'braspag/cryptography'
require 'braspag/connection'

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
