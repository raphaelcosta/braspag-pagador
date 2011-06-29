#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Crypto::Webservice do
  let!(:merchant_id) {"{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"}
  let!(:connection) {Braspag::Connection.new(merchant_id, :test)}
  let!(:crypt) {Braspag::Crypto::Webservice.new(connection)}
  
    context "ao encriptar dados" do
      # before :each do
      #         @key = "j23hn34jkb34n"
      #         respond_with "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><EncryptRequestResponse xmlns='https://www.pagador.com.br/webservice/BraspagGeneralService'><EncryptRequestResult>#{@key}</EncryptRequestResult></EncryptRequestResponse></soap:Body></soap:Envelope>"
      #       end

      it "deve realiza-lo a partir de um mapa de chaves e valores" do
        #request_should_contain(expected)
        crypt.encrypt(:nome => "Chapulin", :sobrenome => "Colorado").should == "XXXX"
      end

      it "deve devolver o resultado como uma string" do
        crypt.encrypt(:key => "value").should == "XXXX"
      end
    end

    context "ao decriptar os dados" do
      # before :each do
      #        respond_with "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><DecryptRequestResponse xmlns='https://www.pagador.com.br/webservice/BraspagGeneralService'><DecryptRequestResult><string>CODPAGAMENTO=18</string><string>VENDAID=teste123</string><string>VALOR=100</string><string>PARCELAS=1</string><string>NOME=comprador</string></DecryptRequestResult></DecryptRequestResponse></soap:Body></soap:Envelope>"
      #      end


      it "deve realiza-lo a partir de uma string criptografada" do
        #request_should_contain(expected)
        crypt.decrypt("{sdfsdf}")
      end

      it "deve retornar o resultado como um mapa de valores" do
        crypt.decrypt("{sdfsdf34543534}")[:parcelas].should eql("1")
      end
    end
end