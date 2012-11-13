#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Crypto::Webservice do

  let(:merchant_id) { "merchant_id" }
  let(:connection) do
    conn = double(Braspag::Connection)
    conn.stub(:merchant_id => merchant_id)
    conn.stub(:url_for => 'fakeurl')
    conn
  end
  
  let(:poster) { mock }
  
  describe "encrypt" do
    let(:key) {"XXXXX"}

    it "should return error with invalid data after process" do
      body_invalid = <<-EOXML
SERVER was unable to process
EOXML
      poster.stub(:do_post => mock(:body => body_invalid))
      Braspag::Poster.should_receive(:new).with(connection, 'fakeurl').and_return(poster)

      expect {
        Braspag::Crypto::Webservice.new.encrypt(connection, {key: key})
      }.to raise_error(RuntimeError, 'UnknownError')
    end

    it "should return error with invalid merchant_id" do
      body_invalid = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<soap:Body><EncryptRequestResponse xmlns="https://www.pagador.com.br/webservice/BraspagGeneralService">
<EncryptRequestResult>Erro BP 011</EncryptRequestResult></EncryptRequestResponse>
</soap:Body></soap:Envelope>
EOXML
      
      poster.stub(:do_post => mock(:body => body_invalid))
      Braspag::Poster.should_receive(:new).with(connection, 'fakeurl').and_return(poster)

      expect {
        Braspag::Crypto::Webservice.new.encrypt(connection, {key: key})
      }.to raise_error(RuntimeError, 'InvalidMerchantId')
    end

    it "should return error with invalid ip" do
      body_invalid = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<soap:Body><EncryptRequestResponse xmlns="https://www.pagador.com.br/webservice/BraspagGeneralService">
<EncryptRequestResult>Erro BP 067</EncryptRequestResult></EncryptRequestResponse>
</soap:Body></soap:Envelope>
EOXML
      poster.stub(:do_post => mock(:body => body_invalid))
      Braspag::Poster.should_receive(:new).with(connection, 'fakeurl').and_return(poster)

      expect {
        Braspag::Crypto::Webservice.new.encrypt(connection, {key: key})
      }.to raise_error(RuntimeError, 'InvalidIP')
      
    end

    it "should return a string" do
        valid_body = <<-EOXML
<?xml version='1.0' encoding='utf-8'?>
<soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'>
<soap:Body>
<EncryptRequestResponse xmlns='https://www.pagador.com.br/webservice/BraspagGeneralService'>
<EncryptRequestResult>#{key}</EncryptRequestResult>
</EncryptRequestResponse>
</soap:Body></soap:Envelope>
              EOXML
        
        poster.stub(:do_post => mock(:body => valid_body))
        Braspag::Poster.should_receive(:new).with(connection, 'fakeurl').and_return(poster)

        resp = Braspag::Crypto::Webservice.new.encrypt(connection, {key: key})
        resp.should eq(key)
    end
  end

  describe "decrypt" do
    let(:crypt_string) {"{sdfsdf34543534}"}
    it "should return error with invalid data" do
      body_invalid = <<-EOXML
SERVER was unable to process
EOXML
      poster.stub(:do_post => mock(:body => body_invalid))
      Braspag::Poster.should_receive(:new).with(connection, 'fakeurl').and_return(poster)

      expect {
        Braspag::Crypto::Webservice.new.decrypt(connection, crypt_string)
      }.to raise_error(RuntimeError, 'UnknownError')
      
    end

    it "should return error with invalid ip" do
      body_invalid = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
<soap:Body><DecryptRequestResponse xmlns="https://www.pagador.com.br/webservice/BraspagGeneralService">
<DecryptRequestResult><string>Erro BP 068</string></DecryptRequestResult>
</DecryptRequestResponse></soap:Body></soap:Envelope>
EOXML
     poster.stub(:do_post => mock(:body => body_invalid))
     Braspag::Poster.should_receive(:new).with(connection, 'fakeurl').and_return(poster)

     expect {
       Braspag::Crypto::Webservice.new.decrypt(connection, crypt_string)
     }.to raise_error(RuntimeError, 'InvalidIP')
    end

    it "should return a string" do
        valid_body = <<-EOXML
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

        poster.stub(:do_post => mock(:body => valid_body))
        Braspag::Poster.should_receive(:new).with(connection, 'fakeurl').and_return(poster)

        resp = Braspag::Crypto::Webservice.new.decrypt(connection, crypt_string)
        resp.should eq({:codpagamento=>"18", :vendaid=>"teste123", :valor=>"100", :parcelas=>"1", :nome=>"comprador"})
    end
  end
end