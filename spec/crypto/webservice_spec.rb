#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Crypto::Webservice do
    pending "encrypt" do
      let!(:key) {"XXXXX"}

      context "consistencies" do
        it "should return error with invalid data" do
          expect {
            Braspag::Crypto::Webservice.encrypt("INVALID DATA")
          }.to raise_error(Braspag::IncompleteParams)
        end

        it "should return error with invalid data after process" do
          body_invalid = <<-EOXML
SERVER was unable to process
EOXML
          FakeWeb.register_uri(:post,
          "https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx",
          :body => body_invalid )
          expect {
            Braspag::Crypto::Webservice.encrypt(:key => "INVALID DATA")
          }.to raise_error(Braspag::UnknownError)
          FakeWeb.clean_registry
        end

        it "should return error with invalid merchant_id" do
          body_invalid = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<soap:Body><EncryptRequestResponse xmlns="https://www.pagador.com.br/webservice/BraspagGeneralService">
<EncryptRequestResult>Erro BP 011</EncryptRequestResult></EncryptRequestResponse>
</soap:Body></soap:Envelope>
EOXML
          FakeWeb.register_uri(:post,
          "https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx",
          :body => body_invalid )
          expect {
            Braspag::Crypto::Webservice.encrypt(:key => "value")
          }.to raise_error(Braspag::InvalidMerchantId)
          FakeWeb.clean_registry
        end

        it "should return error with invalid ip" do
          body_invalid = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<soap:Body><EncryptRequestResponse xmlns="https://www.pagador.com.br/webservice/BraspagGeneralService">
<EncryptRequestResult>Erro BP 067</EncryptRequestResult></EncryptRequestResponse>
</soap:Body></soap:Envelope>
EOXML
          FakeWeb.register_uri(:post,
          "https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx",
          :body => body_invalid )
          expect {
            Braspag::Crypto::Webservice.encrypt(:key => "value")
          }.to raise_error(Braspag::InvalidIP)
          FakeWeb.clean_registry
        end
      end

      it "should return a string" do
          FakeWeb.register_uri(:post,
          "https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx",
          :body => <<-EOXML
<?xml version='1.0' encoding='utf-8'?>
<soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>
<soap:Body>
<EncryptRequestResponse xmlns='https://www.pagador.com.br/webservice/BraspagGeneralService'>
<EncryptRequestResult>#{key}</EncryptRequestResult>
</EncryptRequestResponse>
</soap:Body></soap:Envelope>
                EOXML
          )
          Braspag::Crypto::Webservice.encrypt(:key => "value").should == key
          FakeWeb.clean_registry
      end
    end

    pending "when decrypt data" do

      context "consistencies" do
        it "should return error with invalid data" do
          expect {
            Braspag::Crypto::Webservice.decrypt(1213123)
          }.to raise_error(Braspag::IncompleteParams)
        end

        it "should return error with invalid data" do
          body_invalid = <<-EOXML
SERVER was unable to process
EOXML
          FakeWeb.register_uri(:post,
          "https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx",
          :body => body_invalid )
          expect {
            Braspag::Crypto::Webservice.decrypt("{sdfsdf34543534}")
          }.to raise_error(Braspag::UnknownError)
          FakeWeb.clean_registry
        end

        it "should return error with invalid ip" do
          body_invalid = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<soap:Body><DecryptRequestResponse xmlns="https://www.pagador.com.br/webservice/BraspagGeneralService">
<DecryptRequestResult><string>Erro BP 068</string></DecryptRequestResult>
</DecryptRequestResponse></soap:Body></soap:Envelope>
EOXML
         FakeWeb.register_uri(:post,
         "https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx",
         :body => body_invalid )
         expect {
            Braspag::Crypto::Webservice.decrypt("{sdfsdf34543534}")
          }.to raise_error(Braspag::InvalidIP)
          FakeWeb.clean_registry
        end
      end

      it "should return a string" do
          FakeWeb.register_uri(:post,
          "https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx",
          :body => <<-EOXML
<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>
<soap:Body><DecryptRequestResponse xmlns='https://www.pagador.com.br/webservice/BraspagGeneralService'>
<DecryptRequestResult>
<string>CODPAGAMENTO=18</string>
<string>VENDAID=teste123</string>
<string>VALOR=100</string>
<string>PARCELAS=1</string>
<string>NOME=comprador</string>
</DecryptRequestResult></DecryptRequestResponse>
</soap:Body></soap:Envelope>
                EOXML
          )
          Braspag::Crypto::Webservice.decrypt("{sdfsdf34543534}")[:parcelas].should eql("1")
          FakeWeb.clean_registry
      end

    end
end