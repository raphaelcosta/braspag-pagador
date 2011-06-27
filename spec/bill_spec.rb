#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Bill do

  #TODO Checkar Tamanhos segundo tabela do braspag
  #TODO Melhorar conexao
  #TODO Refatorar nomes dos testes para ingles
  #TODO Sugar Syntax p/ aceitar objetos data no expirtaionDate
  #TODO Parser objeto de retorno no expirtionDate deve retornar um objeto DateTime
  #TODO Transformar numeros magicos em symbols, por exemplo metodo de pagamento pode ser :real ao inves de 10

  before do
    @merchant_id = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
    @connection = Braspag::Connection.new(@merchant_id, :test)
  end

  describe ".new" do

    it "should raise an error when no connection is given" do
      expect {
        Braspag::Bill.new("", {})
      }.to raise_error(Braspag::Bill::InvalidConnection)
    end

    it "should raise an error when :order_id is not present" do
      expect {
        Braspag::Bill.new(@connection, {
          :amount => "100,00",
          :payment_method => "06"
        })
      }.to raise_error(Braspag::Bill::IncompleteParams)
    end

    it "should raise an error when :amount is not present" do
       expect {
         Braspag::Bill.new(@connection, {
           :order_id => "12",
           :payment_method => "06"
         })
       }.to raise_error(Braspag::Bill::IncompleteParams)
    end

    it "should raise an error when :payment_method is not present" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "13",
          :amount => "120,00"
        })
      }.to raise_error(Braspag::Bill::IncompleteParams)
    end

    it "should raise an error when :order_id is less than 1 character" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "",
          :amount => "123,00",
          :payment_method => "06"
        })
      }.to raise_error(Braspag::Bill::InvalidOrderId)
    end

    it "should raise an error when :order_id is more than 50 characters" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "1" * 51,
          :amount => "12,00",
          :payment_method => "06"
        })
      }.to raise_error(Braspag::Bill::InvalidOrderId)
    end

    it "should raise an error when :customer_name is less than 1 character" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "102",
          :amount => "42,00",
          :payment_method => "06",
          :customer_name => ""
        })
      }.to raise_error(Braspag::Bill::InvalidCustomerName)
    end

    it "should raise an error when :customer_name is more than 255 characters" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "112",
          :amount => "121,00",
          :payment_method => "06",
          :customer_name => "A" * 256
        })
      }.to raise_error(Braspag::Bill::InvalidCustomerName)
    end

    it "should raise an error when :customer_id is less than 11 characters" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "23",
          :amount => "251,00",
          :payment_method => "06",
          :customer_id => "2" * 10
        })
      }.to raise_error(Braspag::Bill::InvalidCustomerId)
    end

    it "should raise an error when :customer_id is more than 18 characters" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "90",
          :amount => "90,00",
          :payment_method => "06",
          :customer_id => "3" * 19
        })
      }.to raise_error(Braspag::Bill::InvalidCustomerId)
    end

    it "should raise an error when :number is less than 1 character" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "900",
          :amount => "92,00",
          :payment_method => "06",
          :number => ""
        })
      }.to raise_error(Braspag::Bill::InvalidNumber)
    end

    it "should raise an error when :number is more than 255 characters" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "91",
          :amount => "80,00",
          :payment_method => "06",
          :number => "5" * 256
        })
      }.to raise_error(Braspag::Bill::InvalidNumber)
    end

    it "should raise an error when :instructions is less than 1 character" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "76",
          :amount => "50,00",
          :payment_method => "06",
          :instructions => ""
        })
      }.to raise_error(Braspag::Bill::InvalidInstructions)
    end

    it "should raise an error when :instructions is more than 512 characters" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "65",
          :amount => "210,00",
          :payment_method => "06",
          :instructions => "O" * 513
        })
      }.to raise_error(Braspag::Bill::InvalidInstructions)
    end

    it "should raise an error when :expiration_date is more or less than 8 characters" do
      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "34",
          :amount => "245,00",
          :payment_method => "06",
          :expiration_date => "1" * 7
        })
      }.to raise_error(Braspag::Bill::InvalidExpirationDate)

      expect {
        Braspag::Bill.new(@connection, {
          :order_id => "67",
          :amount => "321,00",
          :payment_method => "06",
          :expiration_date => "2" * 9
        })
      }.to raise_error(Braspag::Bill::InvalidExpirationDate)
    end

  end

  describe ".generate" do

    context "with correct data" do

      before do
        xml = <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                             xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount>3</amount>
          <boletoNumber>70031</boletoNumber>
          <expirationDate>2011-06-27T00:00:00-03:00</expirationDate>
          <url>https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=34ae7d96-aa65-425a-b893-55791cb6a4df</url>
          <returnCode>0</returnCode>)
          <status>0</status>
        </PagadorBoletoReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        @bill =  Braspag::Bill.new(@connection , {
          :order_id => 1,
          :amount => 3,
          :payment_method => 10
        })
        @response = @bill.generate
      end

      after do
        FakeWeb.clean_registry
      end

      it "should return a public url for the invoice" do
        @response[:url].should == "https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=34ae7d96-aa65-425a-b893-55791cb6a4df"
      end

      it "should return 0 (waiting payment) as the status" do
        @response[:status].should == "0"
      end

      it "should return 0 (success) as the return_code" do
        @response[:return_code].should == "0"
      end

      it "should return 3 as the amount" do
        @response[:amount].should == "3"
      end

      it "should return the invoice number" do
        @response[:number].should == "70031"
      end

      it "should return the expiration date of the invoice" do
        @response[:expiration_date].should == "2011-06-27T00:00:00-03:00"
      end

    end

    context "with incorrect data" do

      it "should raise an error for invalid :merchantId" do
        xml = <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                             xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount xsi:nil="true" />
          <expirationDate xsi:nil="true" />
          <returnCode>1</returnCode>
          <message>Invalid merchantId</message>
          <status xsi:nil="true" />
        </PagadorBoletoReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        connection = Braspag::Connection.new("{12345678-1234-1234-1234-123456789000}", :test)

        expect {
          bill = Braspag::Bill.new(connection, {
            :order_id => 1,
            :amount => 3,
            :payment_method => 10
          })
          bill.generate
        }.to raise_error(Braspag::InvalidMerchantId)

        FakeWeb.clean_registry
      end

      it "should raise an error for invalid :number" do
        xml = <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                             xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount xsi:nil="true" />
          <expirationDate xsi:nil="true" />
          <returnCode>1</returnCode>
          <message>Input string was not in a correct format.</message>
          <status xsi:nil="true" />
        </PagadorBoletoReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new(@connection, {
            :number => "A" * 50,
            :order_id => "x",
            :amount => 3,
            :payment_method => 10
          })
          bill.generate
        }.to raise_error(Braspag::Bill::InvalidStringFormat)

        FakeWeb.clean_registry
      end

      it "should raise an error for invalid :payment_method" do
        xml = <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                             xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount xsi:nil="true" />
          <expirationDate xsi:nil="true" />
          <returnCode>3</returnCode>
          <message>Invalid payment method</message>
          <status xsi:nil="true" />
        </PagadorBoletoReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new(@connection, {
            :order_id => 1,
            :amount => "0000",
            :payment_method => 10
          })
          bill.generate
        }.to raise_error(Braspag::Bill::InvalidPaymentMethod)

        FakeWeb.clean_registry
      end

      it "should raise an error for invalid :amount" do
        xml = <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                             xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount xsi:nil="true" />
          <expirationDate xsi:nil="true" />
          <returnCode>1</returnCode>
          <message>Invalid purchase amount</message>
          <status xsi:nil="true" />
        </PagadorBoletoReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new(@connection, {
            :order_id => 1,
            :amount => -33,
            :payment_method => 10
          })
          bill.generate
        }.to raise_error(Braspag::Bill::InvalidAmount)

        FakeWeb.clean_registry
      end

      it "should raise an error for unknown problems" do
        xml = <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                             xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount xsi:nil="true" />
          <expirationDate xsi:nil="true" />
          <returnCode>1</returnCode>
          <message>Invalid server</message>
          <status xsi:nil="true" />
        </PagadorBoletoReturn>
        EOXML

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new(@connection, {
            :order_id => 1,
            :amount => 3,
            :payment_method => "10"
          })
          bill.generate
        }.to raise_error(Braspag::Bill::UnknownError)

        FakeWeb.clean_registry
      end

    end

  end

end
