module  Braspag
  class Response
    attr_reader :params, :message, :test, :authorization, :avs_result, :cvv_result

    def success?
      @success
    end

    def test?
      @test
    end

    def fraud_review?
      @fraud_review
    end

    def initialize(success, message, params = {}, options = {})
      @success, @message, @params = success, message, params.stringify_keys
      @test = options[:test] || false
      @authorization = options[:authorization]
      @fraud_review = options[:fraud_review]
      @avs_result = {:code => nil}
      @cvv_result = {:code => nil}
    end
  end
  
end