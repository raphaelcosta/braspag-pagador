require "rbraspag/version"

ENV["RACK_ENV"] ||= "development"

require 'bundler'

Bundler.setup

require "cs-httpi"
require "json"
require "nokogiri"

Bundler.require(:default, ENV["RACK_ENV"].to_sym)

require 'rbraspag/connection'
require 'rbraspag/crypto/jar_webservice'
require 'rbraspag/crypto/webservice'
require 'rbraspag/bill'
require 'rbraspag/credit_card'
require 'rbraspag/eft'
require 'rbraspag/errors'
require 'rbraspag/utils'

module Braspag
  class Production
    BASE_URL = 'https://www.pagador.com.br'
  end

  class Test
    BASE_URL = 'https://homologacao.pagador.com.br'
  end
end