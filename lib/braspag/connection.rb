module Braspag
  class Connection
    class InvalidMerchantId < Exception ; end

    attr_reader :base_url, :environment, :merchant_id

    def initialize(merchant_id, environment = :production)
      raise InvalidMerchantId unless merchant_id.length == 38
      raise InvalidMerchantId unless merchant_id.match /\{[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}\}/i

      environment = :test unless environment.eql? :production
      @environment = eval(environment.to_s.capitalize)
      @base_url = @environment::BASE_URL
      @merchant_id = merchant_id
    end
  end
end
