module Braspag
  class Poster
    def initialize(request)
      @request = request
    end

    def do_post(method, data)
      Braspag::logger.info("[Braspag] ##{method}: #{@request.url}, data: #{mask_data(data).inspect}") if Braspag::logger

      response = ::HTTPI.post @request

      Braspag::logger.info("[Braspag] ##{method} returns: #{response.body.inspect}") if Braspag::logger

      response
    end

    private

    def mask_data(data)
      copy_data = data.dup
      copy_data['cardNumber'] = "************%s" % copy_data['cardNumber'][-4..-1] if copy_data['cardNumber']
      copy_data['securityCode'] = "***" if copy_data['securityCode']
      copy_data
    end
  end
end
