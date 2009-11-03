module Braspag
  class Connection
    attr_reader :base_url, :environment, :merchant_id

    def initialize(merchant_id, environment = :production)
      environment = :test if environment.eql? 'staging'
      @environment = eval(environment.to_s.capitalize)
      @base_url = @environment::BASE_URL
      @merchant_id = merchant_id
    end
  end
end
