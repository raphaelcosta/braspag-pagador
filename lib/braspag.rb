ENV["RACK_ENV"] ||= "development"

require 'bundler'

Bundler.setup

Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require 'braspag/connection'
require 'braspag/crypto/jar_webservice'
require 'braspag/crypto/webservice'
require 'braspag/bill'
require 'braspag/credit_card'
require 'braspag/eft'
require 'braspag/errors'

module Braspag
  class Production
    BASE_URL = 'https://www.pagador.com.br'
  end

  class Test
    BASE_URL = 'https://homologacao.pagador.com.br'
  end
end
