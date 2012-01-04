#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::CreditCard do
  let!(:braspag_url) { "https://homologacao.pagador.com.br" }
  let!(:braspag_query_url) { "https://homologacao.pagador.com.br/pagador/webservice/pedido.asmx" }

  describe ".authorize" do
    it "should raise an error when :order_id is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :customer_name => "W" * 21,
         :amount => "100.00",
         :payment_method => :redecard,
         :holder => "Joao Maria Souza",
         :card_number => "9" * 10,
         :expiration => "10/12",
         :security_code => "123",
         :number_payments => 1,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :customer_name is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :amount => "100.00",
         :payment_method => :redecard,
         :holder => "Joao Maria Souza",
         :card_number => "9" * 10,
         :expiration => "10/12",
         :security_code => "123",
         :number_payments => 1,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :amount is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :customer_name => "",
         :payment_method => :redecard,
         :holder => "Joao Maria Souza",
         :card_number => "9" * 10,
         :expiration => "10/12",
         :security_code => "123",
         :number_payments => 1,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :payment_method is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :customer_name => "",
         :amount => "100.00",
         :holder => "Joao Maria Souza",
         :card_number => "9" * 10,
         :expiration => "10/12",
         :security_code => "123",
         :number_payments => 1,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :holder is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :customer_name => "",
         :payment_method => :redecard,
         :amount => "100.00",
         :card_number => "9" * 10,
         :expiration => "10/12",
         :security_code => "123",
         :number_payments => 1,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :card_number is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :customer_name => "",
         :payment_method => :redecard,
         :amount => "100.00",
         :holder => "Joao Maria Souza",
         :expiration => "10/12",
         :security_code => "123",
         :number_payments => 1,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :expiration is not present" do
      expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :customer_name => "",
         :payment_method => :redecard,
         :amount => "100.00",
         :holder => "Joao Maria Souza",
         :card_number => "9" * 10,
         :security_code => "123",
         :number_payments => 1,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :security_code is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :customer_name => "AAAAAAAA",
         :payment_method => :redecard,
         :amount => "100.00",
         :holder => "Joao Maria Souza",
         :expiration => "10/12",
         :card_number => "9" * 10,
         :number_payments => 1,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :number_payments is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :customer_name => "AAAAAAAA",
         :payment_method => :redecard,
         :amount => "100.00",
         :holder => "Joao Maria Souza",
         :expiration => "10/12",
         :card_number => "9" * 10,
         :type => 0
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :type is not present" do
     expect {
       Braspag::CreditCard.authorize({
         :order_id => "1" * 5,
         :customer_name => "AAAAAAAA",
         :payment_method => :redecard,
         :amount => "100.00",
         :holder => "Joao Maria Souza",
         :expiration => "10/12",
         :card_number => "9" * 10,
         :number_payments => 1
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    let!(:valid_params) {
      {
        :order_id => "1" * 5,
        :customer_name => "AAAAAAAA",
        :payment_method => :amex_2p,
        :amount => "100.00",
        :holder => "Joao Maria Souza",
        :expiration => "10/12",
        :card_number => "9" * 10,
        :security_code => "123",
        :number_payments => 1,
        :type => 0
      }
    }

    it "should raise an error when :order_id is more than 20 characters" do
      expect {
        params = valid_params
        params[:order_id] = "A" * 21
        Braspag::CreditCard.authorize(params)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when :customer_name is more than 100 characters" do
      expect {
        params = valid_params
        params[:customer_name] = "B" * 101
        Braspag::CreditCard.authorize(params)
      }.to raise_error(Braspag::InvalidCustomerName)
    end

    it "should raise an error when :amount is more than 10 characters" do
      expect {
        params = valid_params
        params[:amount] = "1234567890,00"
        Braspag::CreditCard.authorize(params)
      }.to raise_error(Braspag::InvalidAmount)
    end

    it "should raise an error when :holder is more than 100 characters" do
      expect {
        params = valid_params
        params[:holder] = "E" * 101
        Braspag::CreditCard.authorize(params)
      }.to raise_error(Braspag::InvalidHolder)
    end

    it "should raise an error when :expiration is more than 7 characters" do
      expect {
        params = valid_params
        params[:expiration] = "7" * 8
        Braspag::CreditCard.authorize(params)
      }.to raise_error(Braspag::InvalidExpirationDate)
    end

    it "should raise an error when :security_code is more than 4 characters" do
      expect {
        params = valid_params
        params[:security_code] = "9" * 5
        Braspag::CreditCard.authorize(params)
      }.to raise_error(Braspag::InvalidSecurityCode)
    end

    it "should raise an error when :number_payments is more than 2 characters" do
      expect {
        params = valid_params
        params[:number_payments] = "123"
        Braspag::CreditCard.authorize(params)
      }.to raise_error(Braspag::InvalidNumberPayments)
    end

    it "should raise an error when :type is more than 1 character" do
      expect {
        params = valid_params
        params[:type] = "123"
        Braspag::CreditCard.authorize(params)
      }.to raise_error(Braspag::InvalidType)
    end

    let!(:params) {
      {
        :order_id => "123456",
        :customer_name => "Teste",
        :payment_method => :amex_2p,
        :amount => 1.3,
        :holder => "teste",
        :expiration => "05/13",
        :card_number => "345678000000007",
        :security_code => "1234",
        :number_payments => "1",
        :type => "0"
      }
    }

    context "with a successful transaction" do

      it "should return an array with :status => 1" do
        xml = <<-EOXML
          <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>2</amount>
            <authorisationNumber>733610</authorisationNumber>
            <message>Transaction Successful</message>
            <returnCode>0</returnCode>
            <status>1</status>
            <transactionId>398662</transactionId>
          </PagadorReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Pagador.asmx/Authorize", :body => xml)

        result = Braspag::CreditCard.authorize(params)
        result[:status].should == "1"

        FakeWeb.clean_registry
      end

    end

    context "with a unsuccessful transaction" do

      it "should return an array with :status => 2" do
        invalid_params = params
        invalid_params[:security_code] = 1

        xml = <<-EOXML
          <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>5</amount>
            <message>Payment Server detected an error</message>
            <returnCode>7</returnCode>
            <status>2</status>
            <transactionId>0</transactionId>
          </PagadorReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Pagador.asmx/Authorize", :body => xml)

        result = Braspag::CreditCard.authorize(invalid_params)
        result[:status].should == "2"

        FakeWeb.clean_registry
      end

    end

    context "when a internal server error occurs on the gateway" do

      it "should return an array with :status => null" do
        invalid_params = params
        invalid_params[:security_code] = "1"

        xml = <<-EOXML
          <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>5</amount>
            <message>Payment Server detected an error</message>
            <returnCode>7</returnCode>
            <status>null</status>
            <transactionId>0</transactionId>
          </PagadorReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Pagador.asmx/Authorize", :body => xml)

        result = Braspag::CreditCard.authorize(invalid_params)
        result[:status].should == "null"

        FakeWeb.clean_registry
      end

    end

  end

  describe ".capture" do

    it "should raise an error when :order_id is more than 20 characters" do
      expect {
        Braspag::CreditCard.capture(("A" * 21))
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should parse all the XML fields" do
      xml = <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount>0.01</amount>
          <message>Capture Successful</message>
          <returnCode>07</returnCode>
          <status>0</status>
        </PagadorReturn>
      EOXML

      FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Pagador.asmx/Capture", :body => xml)

      result = Braspag::CreditCard.capture('123456')

      result[:amount].should_not be_nil
      result[:message].should_not be_nil
      result[:return_code].should_not be_nil
      result[:status].should_not be_nil

      FakeWeb.clean_registry
    end

    context "with a successful capture" do

      it "should return an array with :status => 0" do
        xml = <<-EOXML
          <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>2</amount>
            <message>Approved</message>
            <returnCode>0</returnCode>
            <status>0</status>
          </PagadorReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Pagador.asmx/Capture", :body => xml)

        result = Braspag::CreditCard.capture('123456')
        result[:status].should == "0"

        FakeWeb.clean_registry
      end

    end

    context "with an unsuccessful capture" do

      it "should return an array with :status => 2" do
        xml = <<-EOXML
          <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>0.01</amount>
            <message>Payment Server detected an error</message>
            <returnCode>7</returnCode>
          <status>2</status>
        </PagadorReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Pagador.asmx/Capture", :body => xml)

        result = Braspag::CreditCard.capture("1")
        result[:status].should == "2"

        FakeWeb.clean_registry
      end

    end

    context "when an internal server error occurs on the gateway" do

      it "should return an array with :status => null" do
        xml = <<-EOXML
          <?xml version="1.0" encoding="utf-8"?>
          <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                         xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                         xmlns="https://www.pagador.com.br/webservice/pagador">
            <amount>0.01</amount>
            <message>Payment Server detected an error</message>
            <returnCode>7</returnCode>
            <status>null</status>
          </PagadorReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Pagador.asmx/Capture", :body => xml)

        result = Braspag::CreditCard.capture("1234")
        result[:status].should == "null"

        FakeWeb.clean_registry
      end

    end

    context ".payment_method_from_id" do
      it 'Credit card amex' do
       Braspag::CreditCard::payment_method_from_id(18).should == :amex_2p
       Braspag::CreditCard::payment_method_from_id(18).should be_kind_of Symbol
      end
    end


  describe "#status" do
    it "should raise an error when no order_id is given" do
      expect {
        Braspag::CreditCard.info(nil)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when order_id is empty" do
      expect {
        Braspag::CreditCard.info("")
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when order_id is more than 50 characters" do
      expect {
        Braspag::CreditCard.info("1" * 51)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error for incorrect data" do
      xml = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<DadosCartao xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:xsd="http://www.w3.org/2001/XMLSchema"
           xsi:nil="true"
           xmlns="http://www.pagador.com.br/" />
      EOXML

      FakeWeb.register_uri(:post, "#{braspag_query_url}/GetDadosCartao",
        :body => xml)

      expect {
        Braspag::CreditCard.info("sadpoakjspodqdouq09wduwq")
      }.to raise_error(Braspag::UnknownError)


      expect {
        Braspag::CreditCard.info("asdnasdniousa")
      }.to raise_error(Braspag::UnknownError)

      FakeWeb.clean_registry
    end

    context "with correct data" do

      let(:order_info) {
        xml = <<-EOXML
<DadosCartao xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns="http://www.pagador.com.br/">
  <NumeroComprovante>225296</NumeroComprovante>
  <Autenticada>false</Autenticada>
  <NumeroAutorizacao>557593</NumeroAutorizacao>
  <NumeroCartao>345678*****0007</NumeroCartao>
  <NumeroTransacao>101001225645</NumeroTransacao>
</DadosCartao>
        EOXML

        FakeWeb.register_uri(:post, "#{braspag_query_url}/GetDadosCartao",
          :body => xml)
        order_info = Braspag::CreditCard.info("12345")
        FakeWeb.clean_registry
        order_info
      }

      it "should return a Hash" do
        order_info.should be_kind_of Hash
      end

      {
        :checking_number => "225296",
        :certified => "false",
        :autorization_number => "557593",
        :card_number => "345678*****0007",
        :transaction_number => "101001225645"
      }.each do |key, value|

        it "should return a Hash with :#{key.to_s} key" do
          order_info[key].should == value
        end
      end
    end
  end


  end
end
