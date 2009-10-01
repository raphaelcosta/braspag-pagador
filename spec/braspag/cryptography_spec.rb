require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Cryptography do
  before :each do
    @merchant_id = "{84BE9T9T-75FC-6C74-7K4B-AE469C2A07C3}"
    @connection = Braspag::Connection.new(@merchant_id, :test)
    @cryptography = Braspag::Cryptography.new(@connection)
  end

  it "deve reconhecer a base_url da conexão" do
    @cryptography.class.uri.should be_start_with(@connection.base_url)
  end

  context "ao encriptar dados" do
    before :each do
      @key = "j23hn34jkb34n"
      response = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><EncryptRequestResponse xmlns='https://www.pagador.com.br/webservice/BraspagGeneralService'><EncryptRequestResult>#{@key}</EncryptRequestResult></EncryptRequestResponse></soap:Body></soap:Envelope>"
      document = @cryptography.parse_soap_response_document(response)
      @cryptography.on_response_document document
      @response = Handsoap::SoapResponse.new(document, mock(Object))
      @cryptography.stub!(:dispatch).and_return(@response)
    end

    it "deve enviar dados a partir de um mapa de chaves e valores" do
      expected = <<STRING
<?xml version='1.0' ?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Header />
  <env:Body>
    <tns:EncryptRequest xmlns:tns="https://www.pagador.com.br/webservice/BraspagGeneralService">
      <tns:merchantId>#{@merchant_id}</tns:merchantId>
      <tns:request>
        <tns:string>nome=Chapulin</tns:string>
        <tns:string>sobrenome=Colorado</tns:string>
      </tns:request>
    </tns:EncryptRequest>
  </env:Body>
</env:Envelope>
STRING
      @cryptography.should_receive(:dispatch) do |document, url|
        Handsoap::XmlMason::TextNode.new(document.to_s + "\n").to_s.should eql(Handsoap::XmlMason::TextNode.new(expected).to_s)
        @response
      end
      @cryptography.encrypt_request(:nome => "Chapulin", :sobrenome => "Colorado")
    end

    it "deve devolver a encriptação" do
      @cryptography.encrypt_request(:key => "value").should eql(@key)
    end
  end
end
