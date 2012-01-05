module Braspag
  class Connection
    include Singleton

    PRODUCTION_URL = "https://transaction.pagador.com.br"
    HOMOLOGATION_URL = "https://homologacao.pagador.com.br"

    PRODUCTION_QUERY_URL = "https://query.pagador.com.br/webservices/pagador/pedido.asmx"
    HOMOLOGATION_QUERY_URL = "https://homologacao.pagador.com.br/pagador/webservice/pedido.asmx"

    attr_reader :braspag_url, :braspag_query_url, :merchant_id, :crypto_url, :crypto_key, :options, :environment

    def initialize
      raise InvalidEnv if ENV["RACK_ENV"].nil? || ENV["RACK_ENV"].empty?

      @options = YAML.load_file('config/braspag.yml')[ ENV['RACK_ENV'] ]
      @merchant_id = @options['merchant_id']

      raise InvalidMerchantId unless @merchant_id =~ /\{[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}\}/i

      @crypto_key  = @options["crypto_key"]
      @crypto_url  = @options["crypto_url"]

      @environment = @options["environment"] == 'production' ? 'production' : 'homologation'

      @braspag_url       = self.production? ? PRODUCTION_URL : HOMOLOGATION_URL
      @braspag_query_url = self.production? ? PRODUCTION_QUERY_URL : HOMOLOGATION_QUERY_URL
    end

    def production?
      @environment == 'production'
    end

    def homologation?
      @environment == 'homologation'
    end
  end
end
