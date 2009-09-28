require 'rubygems'
require 'handsoap'

class BraspagCryptography < Handsoap::Service

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

  def on_create_document(doc)
    # register namespaces for the request
    doc.alias 'tns', "#{@base_action_url}"
  end

  def on_response_document(doc)
    # register namespaces for the response
    doc.add_namespace 'ns', "#{@base_action_url}"
  end

  # public methods

  def encrypt_request!
    soap_action = "#{@base_action_url}/EncryptRequest"
    response = invoke('tns:EncryptRequest', soap_action) do |message|
      message.add("merchantId", @merchant_id)
      message.add("request", "nome=ricardo")
    end
    node = response.document.xpath('//ns:EncryptRequestResult').first
    node.to_s
  end

  def decrypt_request!
    soap_action = "#{@base_action_url}/DecryptRequest"
    response = invoke('tns:DecryptRequest', soap_action) do |message|
      #raise "TODO"
    end
  end

  def clear_cache_for_merchant!
    soap_action = "#{@base_action_url}/ClearCacheForMerchant"
    response = invoke('tns:ClearCacheForMerchant', soap_action) do |message|
      #raise "TODO"
    end
  end

  private
  # helpers
  # TODO
end
