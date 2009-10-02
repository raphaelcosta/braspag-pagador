require 'hpricot'
require 'serviceproxy'

module Braspag
  class Cryptography < ServiceProxy::Base
    def initialize(base_url, merchant_id)
      @base_url = base_url
      @merchant_id = merchant_id
      @base_action_url = "https://www.pagador.com.br/webservice/BraspagGeneralService"
      params = {
        :uri => "#{@base_url}/BraspagGeneralService/BraspagGeneralService.asmx",
        :version => 2
      }
      self.class.endpoint params
    end

    def build_encrypt_request(options)
      soap_envelope(options) do |xml|
        xml.merchantId options[:merchant_id]
        xml.request do |request|
          options[:request].each {|r| request.string r }
        end
      end
    end

    def parse_encrypt_request(response)
      xml = Hpricot.XML(response.body)
      xml.inner_text
    end

    def build_decrypt_request(options)
      soap_envelope(options) do |xml|
        xml.merchantId options[:merchant_id]
        xml.cryptString options[:crypt]
        xml.customFields do |fields|
          fields.string ''
        end
      end
    end

    def parse_decrypt_request(response)
      xml = Hpricot.XML(response.body)
      xml.at('DecryptRequestResult').children.map {|node| node.inner_text}
    end
  end
end
