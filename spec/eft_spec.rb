#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Eft do

  let!(:merchant_id) {"{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"}
  let!(:connection) {Braspag::Connection.new(merchant_id, :test)}
  
  
  describe ".new" do

     it "should raise an error when no connection is given" do
       expect {
         Braspag::Eft.new("", {})
       }.to raise_error(Braspag::InvalidConnection)
     end

     it "should raise an error when :order_id is not present" do
       expect {
         Braspag::Eft.new(connection, {
           :amount => "10000",
           :payment_method => "11"
         })
       }.to raise_error(Braspag::IncompleteParams)
     end

     it "should raise an error when :amount is not present" do
        expect {
          Braspag::Eft.new(connection, {
            :order_id => "12",
            :payment_method => "11"
          })
        }.to raise_error(Braspag::IncompleteParams)
     end

     it "should raise an error when :payment_method is not present" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "13",
           :amount => "12000"
         })
       }.to raise_error(Braspag::IncompleteParams)
     end

     it "should raise an error when :order_id is less than 1 character" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "",
           :amount => "12300",
           :payment_method => "11"
         })
       }.to raise_error(Braspag::InvalidOrderId)
     end

     it "should raise an error when :order_id is more than 50 characters" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "1" * 51,
           :amount => "1200",
           :payment_method => "11"
         })
       }.to raise_error(Braspag::InvalidOrderId)
     end

     it "should raise an error when :customer_name is less than 1 character" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "102",
           :amount => "4200",
           :payment_method => "11",
           :customer_name => ""
         })
       }.to raise_error(Braspag::InvalidCustomerName)
     end

     it "should raise an error when :customer_name is more than 255 characters" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "112",
           :amount => "12100",
           :payment_method => "11",
           :customer_name => "A" * 256
         })
       }.to raise_error(Braspag::InvalidCustomerName)
     end

     it "should raise an error when :customer_id is less than 11 characters" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "23",
           :amount => "25100",
           :payment_method => "11",
           :customer_id => "2" * 10
         })
       }.to raise_error(Braspag::InvalidCustomerId)
     end

     it "should raise an error when :customer_id is more than 18 characters" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "90",
           :amount => "9000",
           :payment_method => "11",
           :customer_id => "3" * 19
         })
       }.to raise_error(Braspag::InvalidCustomerId)
     end

     it "should raise an error when :installments is less than 1 character" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "900",
           :amount => "9200",
           :payment_method => "11",
           :installments => ""
         })
       }.to raise_error(Braspag::InvalidInstallments)
     end

     it "should raise an error when :installments is more than 2 characters" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "91",
           :amount => "8000",
           :payment_method => "11",
           :installments => "5" * 3
         })
       }.to raise_error(Braspag::InvalidInstallments)
     end

    it "should raise an error when :installments is not a number" do
        expect {
          Braspag::Eft.new(connection, {
            :order_id => "91",
            :amount => "8000",
            :payment_method => "11",
            :installments => "A" * 2
          })
        }.to raise_error(Braspag::InvalidInstallments)
    end

     it "should raise an error when :has_interest is not boolean" do
       expect {
         Braspag::Eft.new(connection, {
           :order_id => "76",
           :amount => "5000",
           :payment_method => "11",
           :has_interest => []
         })
       }.to raise_error(Braspag::InvalidHasInterest)
     end
   end

  describe ".generate" do
    let!(:crypto_key) {"{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"}
    let!(:braspag_crypto_jar_webservice) {Braspag::Crypto::JarWebservice.new(crypto_key, "http://localhost:9292")}
    let!(:braspag_crypto_webservice) {Braspag::Crypto::Webservice.new(connection)}
    
    
      it "should return form fields in strategy without crypto" do
        html = <<-EOHTML
<form id="form_tef_1234123125" name="form_tef_1234123125" action="https://homologacao.pagador.com.br/pagador/passthru.asp" method="post">
<input type="text" name="VendaId" value="1234123125" />
<input type="text" name="Valor" value="12300" />
<input type="text" name="codpagamento" value="11" />
<input type="text" name="Id_Loja" value="{84BE7E7F-698A-6C74-F820-AE359C2A07C2}" />
      </form>
       <script type="text/javascript" charset="utf-8">
         document.forms["form_tef_1234123125"].submit();
       </script>
        EOHTML

        Braspag::Eft.new(connection , {
          :order_id => "1234123125",
          :amount => "12300",
          :payment_method => "11"
        }).generate.should == html
     end
     
      it "should return form fields in strategy with braspag.jar crypto service" do
            FakeWeb.register_uri(:post, 
            "http://localhost:9292/v1/encrypt.json", 
            :body => <<-EOJSON
            {"encrypt":"5u0ZN5qk8eQNuuGPHrcsk0rfi7YclF6s+ZXCE+G4uG4ztfRJrrOALlf81ra7k7p7"}
            EOJSON
            )

         html = <<-EOHTML
<form id="form_tef_1234123125" name="form_tef_1234123125" action="https://homologacao.pagador.com.br/pagador/passthru.asp" method="post">
<input type="text" name="crypt" value="5u0ZN5qk8eQNuuGPHrcsk0rfi7YclF6s+ZXCE+G4uG4ztfRJrrOALlf81ra7k7p7" />
<input type="text" name="Id_Loja" value="{84BE7E7F-698A-6C74-F820-AE359C2A07C2}" />
      </form>
       <script type="text/javascript" charset="utf-8">
         document.forms["form_tef_1234123125"].submit();
       </script>
        EOHTML

         Braspag::Eft.new(connection , {
           :order_id => "1234123125",
           :amount => "12300",
           :payment_method => "11"
         } , braspag_crypto_jar_webservice ).generate.should == html
         
         FakeWeb.clean_registry
         
      end

      let!(:key) { "12312312312313123123" }
      it "should return form fields in strategy with braspag crypto webservice" do
        
          FakeWeb.register_uri(:post, 
          "https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx", 
          :body => "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><EncryptRequestResponse xmlns='https://www.pagador.com.br/webservice/BraspagGeneralService'><EncryptRequestResult>#{key}</EncryptRequestResult></EncryptRequestResponse></soap:Body></soap:Envelope>" )

         html = <<-EOHTML
<form id="form_tef_1234123125" name="form_tef_1234123125" action="https://homologacao.pagador.com.br/pagador/passthru.asp" method="post">
<input type="text" name="crypt" value="#{key}" />
<input type="text" name="Id_Loja" value="{84BE7E7F-698A-6C74-F820-AE359C2A07C2}" />
      </form>
       <script type="text/javascript" charset="utf-8">
         document.forms["form_tef_1234123125"].submit();
       </script>
        EOHTML

         Braspag::Eft.new(connection , {
           :order_id => "1234123125",
           :amount => "12300",
           :payment_method => "11"
         } , braspag_crypto_webservice ).generate.should == html
         
         FakeWeb.clean_registry
         
      end
      

   end

end
