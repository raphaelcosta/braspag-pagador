#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::CreditCard do

  let!(:merchant_id) { "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}" }
  let!(:connection) { Braspag::Connection.new(merchant_id, :test) }

  describe ".new" do

    it "should raise an error when no connection is given" do
      expect {
        Braspag::CreditCard.new(Object.new)
      }.to raise_error(Braspag::InvalidConnection)
    end

  end

  describe ".authorize" do

    it "should raise an error when :order_id is not present" do
     expect {
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
       Braspag::CreditCard.new(connection).authorize({
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
        Braspag::CreditCard.new(connection).authorize(params)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when :customer_name is more than 100 characters" do
      expect {
        params = valid_params
        params[:customer_name] = "B" * 101
        Braspag::CreditCard.new(connection).authorize(params)
      }.to raise_error(Braspag::InvalidCustomerName)
    end

    it "should raise an error when :amount is more than 10 characters" do
      expect {
        params = valid_params
        params[:amount] = "1234567890,00"
        Braspag::CreditCard.new(connection).authorize(params)
      }.to raise_error(Braspag::InvalidAmount)
    end

    it "should raise an error when :holder is more than 100 characters" do
      expect {
        params = valid_params
        params[:holder] = "E" * 101
        Braspag::CreditCard.new(connection).authorize(params)
      }.to raise_error(Braspag::InvalidHolder)
    end

    it "should raise an error when :expiration is more than 7 characters" do
      expect {
        params = valid_params
        params[:expiration] = "7" * 8
        Braspag::CreditCard.new(connection).authorize(params)
      }.to raise_error(Braspag::InvalidExpirationDate)
    end

    it "should raise an error when :security_code is more than 4 characters" do
      expect {
        params = valid_params
        params[:security_code] = "9" * 5
        Braspag::CreditCard.new(connection).authorize(params)
      }.to raise_error(Braspag::InvalidSecurityCode)
    end

    it "should raise an error when :number_payments is more than 2 characters" do
      expect {
        params = valid_params
        params[:number_payments] = "123"
        Braspag::CreditCard.new(connection).authorize(params)
      }.to raise_error(Braspag::InvalidNumberPayments)
    end

    it "should raise an error when :type is more than 1 character" do
      expect {
        params = valid_params
        params[:type] = "123"
        Braspag::CreditCard.new(connection).authorize(params)
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

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Pagador.asmx/Authorize", :body => xml)

        result = Braspag::CreditCard.new(connection).authorize(params)
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

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Pagador.asmx/Authorize", :body => xml)

        result = Braspag::CreditCard.new(connection).authorize(invalid_params)
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

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Pagador.asmx/Authorize", :body => xml)

        result = Braspag::CreditCard.new(connection).authorize(invalid_params)
        result[:status].should == "null"

        FakeWeb.clean_registry
      end

    end

  end

  describe ".capture" do

    it "should raise an error when :order_id is more than 20 characters" do
      expect {
        Braspag::CreditCard.new(connection).capture(("A" * 21))
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

      FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Pagador.asmx/Capture", :body => xml)

      result = Braspag::CreditCard.new(connection).capture('123456')

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

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Pagador.asmx/Capture", :body => xml)

        result = Braspag::CreditCard.new(connection).capture('123456')
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

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Pagador.asmx/Capture", :body => xml)

        result = Braspag::CreditCard.new(connection).capture("1")
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

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Pagador.asmx/Capture", :body => xml)

        result = Braspag::CreditCard.new(connection).capture("1234")
        result[:status].should == "null"

        FakeWeb.clean_registry
      end

    end

  end

end

