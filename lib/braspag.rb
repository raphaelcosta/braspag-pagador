require 'rubygems'
require 'bundler/setup'


require 'braspag/connection'
require 'braspag/bill'
require 'braspag/credit_card'


module Braspag
  class Production
    BASE_URL = 'https://www.pagador.com.br'
  end

  class Test
    BASE_URL = 'https://homologacao.pagador.com.br'
  end
end