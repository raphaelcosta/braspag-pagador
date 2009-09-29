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
    doc.alias 'tns', @base_action_url
  end

  def on_response_document(doc)
    # register namespaces for the response
    doc.add_namespace 'ns', @base_action_url
  end

  def encrypt_request!(plain_text)
    invoke_and_parse('EncryptRequest') do |message|
      message.add("tns:merchantId", @merchant_id)
      message.add("tns:request", plain_text)
    end.first
  end

  def decrypt_request!(encripted_text)
    invoke_and_parse('DecryptRequest') do |message|
      message.add("tns:merchantId", @merchant_id)
      message.add("tns:cryptString", encripted_text)
      message.add("tns:customFields") do |sub_message|
        sub_message.add('aaaaa')
      end
    end.first
  end

  def clear_cache_for_merchant!
    invoke_and_parse('ClearCacheForMerchant') do |message|
    end
  end

  private
    def invoke_and_parse(method_name, &block)
      soap_action = "#{@base_action_url}/#{method_name}"
      response = invoke("tns:#{method_name}", soap_action) do |message|
        block.call(message)
      end
      response.document.xpath("//ns:#{method_name}Result").map {|result| result.to_s}
    end
end
