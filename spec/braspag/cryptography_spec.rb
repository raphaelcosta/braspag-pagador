require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Cryptography do
  before do
    @merchant_id = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
    @connection = Braspag::Connection.new(@merchant_id, :test)
    @cryptography = Braspag::Cryptography.new(@connection)
    @fields_to_encrypt = ["nome=ricardo", "cpf=321654987"]
  end

  context "ao encriptar dados" do
    before :each do
      xml = '<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema"><soap:Body><EncryptRequestResponse xmlns="https://www.pagador.com.br/webservice/BraspagGeneralService"><EncryptRequestResult>RblletYGBHp6oH9Y/bu8Mg==</EncryptRequestResult></EncryptRequestResponse></soap:Body></soap:Envelope>'
      document = Handsoap::XmlQueryFront.parse_string(xml, :nokogiri)
      @cryptography.on_response_document document
      @response = Handsoap::SoapResponse.new(document, mock(Object))
    end

    it "deve enviar dados a partir de um mapa de chaves e valores" do
      expected = <<STRING
<?xml version='1.0' ?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Header />
  <env:Body>
    <tns:EncryptRequest xmlns:tns="https://www.pagador.com.br/webservice/BraspagGeneralService">
      <tns:merchantId>{84BE7E7F-698A-6C74-F820-AE359C2A07C2}</tns:merchantId>
      <tns:request>nome=pedro</tns:request>
    </tns:EncryptRequest>
  </env:Body>
</env:Envelope>
STRING
      @cryptography.should_receive(:dispatch) do |document, url|
        Handsoap::XmlMason::TextNode.new(document.to_s + "\n").to_s.should eql(Handsoap::XmlMason::TextNode.new(expected).to_s)
        @response
      end
      @cryptography.encrypt_request!("nome=pedro")
    end

    it "deve especificar https://www.pagador.com.br/webservice/BraspagGeneralService/EncryptRequest como a action de pagamento" do
      @cryptography.should_receive(:dispatch) do |document, url|
        url.should eql("https://www.pagador.com.br/webservice/BraspagGeneralService/EncryptRequest")
        @response
      end
      @cryptography.encrypt_request!(:nome => "pedro")
    end
  end
end
