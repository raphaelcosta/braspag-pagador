#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::CreditCard do

  let!(:merchant_id) { "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}" }
  let!(:connection) { Braspag::Connection.new(merchant_id, :test) }

  describe ".new" do

    it "should raise an error when no connection is given" do
      expect {
        Braspag::CreditCard.new("", {})
      }.to raise_error(Braspag::InvalidConnection)
    end

    it "should raise an error when :order_id is not present" do
     expect {
       Braspag::CreditCard.new(connection, {
         :customer_name => "W" * 21,
         :amount => "100.00",
         :payment_method => 20,
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
       Braspag::CreditCard.new(connection, {
         :order_id => "1" * 5,
         :amount => "100.00",
         :payment_method => 20, # tem uma tabela nos docs
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
       Braspag::CreditCard.new(connection, {
         :order_id => "1" * 5,
         :customer_name => "",
         :payment_method => 20, # tem uma tabela nos docs
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
       Braspag::CreditCard.new(connection, {
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
       Braspag::CreditCard.new(connection, {
         :order_id => "1" * 5,
         :customer_name => "",
         :payment_method => 20,
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
       Braspag::CreditCard.new(connection, {
         :order_id => "1" * 5,
         :customer_name => "",
         :payment_method => 20,
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
       Braspag::CreditCard.new(connection, {
         :order_id => "1" * 5,
         :customer_name => "",
         :payment_method => 20,
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
       Braspag::CreditCard.new(connection, {
         :order_id => "1" * 5,
         :customer_name => "AAAAAAAA",
         :payment_method => 20,
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
       Braspag::CreditCard.new(connection, {
         :order_id => "1" * 5,
         :customer_name => "AAAAAAAA",
         :payment_method => 20,
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
       Braspag::CreditCard.new(connection, {
         :order_id => "1" * 5,
         :customer_name => "AAAAAAAA",
         :payment_method => 20,
         :amount => "100.00",
         :holder => "Joao Maria Souza",
         :expiration => "10/12",
         :card_number => "9" * 10,
         :number_payments => 1
       })
     }.to raise_error(Braspag::IncompleteParams)
    end

    #TODO Verificar validação de tamanho mínimo de todos os campos

    let!(:valid_params) {
      {
        :order_id => "1" * 5,
        :customer_name => "AAAAAAAA",
        :payment_method => 20,
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
        Braspag::CreditCard.new(connection, params)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when :customer_name is more than 100 characters" do
      expect {
        params = valid_params
        params[:customer_name] = "B" * 101
        Braspag::CreditCard.new(connection, params)
      }.to raise_error(Braspag::InvalidCustomerName)
    end

    it "should raise an error when :amount is more than 10 characters" do
      expect {
        params = valid_params
        params[:amount] = "1234567890,00"
        Braspag::CreditCard.new(connection, params)
      }.to raise_error(Braspag::InvalidAmount)
    end

    it "should raise an error when :holder is more than 100 characters" do
      expect {
        params = valid_params
        params[:holder] = "E" * 101
        Braspag::CreditCard.new(connection, params)
      }.to raise_error(Braspag::InvalidHolder)
    end

    it "should raise an error when :expiration is more than 7 characters" do
      expect {
        params = valid_params
        params[:expiration] = "7" * 8
        Braspag::CreditCard.new(connection, params)
      }.to raise_error(Braspag::InvalidExpirationDate)
    end

    it "should raise an error when :security_code is more than 4 characters" do
      expect {
        params = valid_params
        params[:security_code] = "9" * 5
        Braspag::CreditCard.new(connection, params)
      }.to raise_error(Braspag::InvalidSecurityCode)
    end

    it "should raise an error when :number_payments is more than 2 characters" do
      expect {
        params = valid_params
        params[:number_payments] = "123"
        Braspag::CreditCard.new(connection, params)
      }.to raise_error(Braspag::InvalidNumberPayments)
    end

    it "should raise an error when :type is more than 1 character" do
      expect {
        params = valid_params
        params[:type] = "123"
        Braspag::CreditCard.new(connection, params)
      }.to raise_error(Braspag::InvalidType)
    end

  end

  describe ".authorize" do
    let!(:params) {{
      :order_id => "123456",
      :customer_name => "Teste",
      :payment_method => 18,
      :amount => "0,01",
      :holder => "teste",
      :expiration => "05/13",
      :card_number => "345678000000007",
      :security_code => "1234",
      :number_payments => "1",
      :type => "0"
    }}
  end

=begin
  before do
    @merchant_id = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
    @connection = Braspag::Connection.new(@merchant_id, :test)
    @gateway = Braspag::CreditCard.new(@connection)
#    respond_with "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><AuthorizeResponse xmlns='https://www.pagador.com.br/webservice/pagador'><AuthorizeResult><amount>1</amount><authorisationNumber>418270</authorisationNumber><message>Transaction Successful</message><returnCode>0</returnCode><status>1</status><transactionId>128199</transactionId></AuthorizeResult></AuthorizeResponse></soap:Body></soap:Envelope>"
  end

  context "on authorize!" do
    before :each do
      #respond_with "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><AuthorizeResponse xmlns='https://www.pagador.com.br/webservice/pagador'><AuthorizeResult><amount>1</amount><authorisationNumber>418270</authorisationNumber><message>Transaction Successful</message><returnCode>0</returnCode><status>1</status><transactionId>128199</transactionId></AuthorizeResult></AuthorizeResponse></soap:Body></soap:Envelope>"
    end

    pending "deve enviar dados para webservice de autorizacao" do
      expected = <<STRING
  <?xml version='1.0' ?>
  <env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
    <env:Header />
    <env:Body>
      <tns:Authorize xmlns:tns="https://www.pagador.com.br/webservice/pagador">
        <tns:merchantId>#{@merchant_id}</tns:merchantId>
        <tns:orderId>teste564</tns:orderId>
        <tns:customerName>comprador de teste</tns:customerName>
        <tns:amount>1,00</tns:amount>
      </tns:Authorize>
    </env:Body>
  </env:Envelope>
STRING
#      request_should_contain(expected)
#      @gateway.authorize! :orderId => "teste564", :customerName => "comprador de teste", :amount => "1,00"
    end

    pending "deve devolver o resultado em um mapa" do
#      map = {"amount" =>"1", "authorisationNumber" => "418270", "message" => "Transaction Successful", "returnCode" => "0", "status" => "1", "transactionId" => "128199"}
#      @gateway.authorize!(:orderId => "teste564", :customerName => "comprador de teste", :amount => "1,00").should == map
    end
  end

  context "on capture!" do
    before :each do
#      respond_with "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><CaptureResponse xmlns='https://www.pagador.com.br/webservice/pagador'><CaptureResult><amount>1</amount><authorisationNumber>418270</authorisationNumber><message>Transaction Successful</message><returnCode>0</returnCode><status>1</status><transactionId>128199</transactionId></CaptureResult></CaptureResponse></soap:Body></soap:Envelope>"
    end

    pending "deve enviar dados para webservice de captura" do
      expected = <<STRING
  <?xml version='1.0' ?>
  <env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
    <env:Header />
    <env:Body>
      <tns:Capture xmlns:tns="https://www.pagador.com.br/webservice/pagador">
        <tns:merchantId>#{@merchant_id}</tns:merchantId>
        <tns:orderId>teste564</tns:orderId>
      </tns:Capture>
    </env:Body>
  </env:Envelope>
STRING
#      request_should_contain(expected)
#      @gateway.capture! :orderId => "teste564"
    end

    pending "deve devolver o resultado em um mapa" do
#      map = {"amount" =>"1", "authorisationNumber" => "418270", "message" => "Transaction Successful", "returnCode" => "0", "status" => "1", "transactionId" => "128199"}
#      @gateway.capture!(:orderId => "teste564").should == map
    end
  end
=end

end

