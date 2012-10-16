module Braspag
  class Poster
    def initialize(url)
      @request = ::HTTPI::Request.new(url)
    end

    def do_post(method, data)
      @request.body = data
      @request.proxy = Braspag.proxy_address if Braspag.proxy_address

      with_logger(method) do
        ::HTTPI.post @request
      end
    end

    private

    def with_logger(method)
      if Braspag::logger
        Braspag::logger.info("[Braspag] ##{method}: #{@request.url}, data: #{mask_data(@request.body).inspect}")
        response = yield
        Braspag::logger.info("[Braspag] ##{method} returns: #{response.body.inspect}")
      else
        response = yield
      end
      response
    end

    def mask_data(data)
      copy_data = data.dup
      copy_data['cardNumber'] = "************%s" % copy_data['cardNumber'][-4..-1] if copy_data['cardNumber']
      copy_data['securityCode'] = "***" if copy_data['securityCode']
      copy_data
    end
  end
end
