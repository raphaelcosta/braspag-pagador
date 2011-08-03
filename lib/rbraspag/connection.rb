module Braspag
  class Connection
    include Singleton
    class InvalidMerchantId < Exception ; end
    class InvalidEnv < Exception ; end
    class InvalidBraspagUrl < Exception ; end

    attr_reader :braspag_url, :merchant_id, :crypto_url, :crypto_key

    def initialize
      raise InvalidEnv if ENV["RACK_ENV"].nil? || ENV["RACK_ENV"].empty?
      options = YAML.load_file("config/braspag.yml")
      options = options[ENV["RACK_ENV"]]

      merchant_id = options["merchant_id"]

      raise InvalidMerchantId unless merchant_id.length == 38
      raise InvalidMerchantId unless merchant_id.match /\{[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}\}/i
      raise InvalidBraspagUrl if options["braspag_url"].nil? || options["braspag_url"].empty?

      @crypto_key = options["crypto_key"]
      @crypto_url = options["crypto_url"]
      @braspag_url = options["braspag_url"]
      @merchant_id = merchant_id
    end
  end
end
