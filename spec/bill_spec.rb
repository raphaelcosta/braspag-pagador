#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Bill do
  let!(:braspag_url) { "https://homologacao.pagador.com.br" }
  
  describe ".new" do

    it "should raise an error when :order_id is not present" do
      expect {
        Braspag::Bill.new( {
            :amount => "100.00",
            :payment_method => :bradesco
          })
      }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :amount is not present" do
      expect {
        Braspag::Bill.new( {
            :order_id => "12",
            :payment_method => :bradesco
          })
      }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when :payment_method is not present" do
      expect {
        Braspag::Bill.new( {
            :order_id => "13",
            :amount => "120.00"
          })
      }.to raise_error(Braspag::IncompleteParams)
    end

    it "should raise an error when invalid string :payment_method" do
      expect {
        Braspag::Bill.new( {
            :order_id => "13",
            :amount => "120.00",
            :payment_method => "10"
          })
      }.to raise_error(Braspag::InvalidPaymentMethod)
    end

    it "should raise an error when invalid symbol :payment_method" do
      expect {
        Braspag::Bill.new( {
            :order_id => "13",
            :amount => "120.00",
            :payment_method => :invalid
          })
      }.to raise_error(Braspag::InvalidPaymentMethod)
    end

    it "should raise an error when :order_id is less than 1 character" do
      expect {
        Braspag::Bill.new( {
            :order_id => "",
            :amount => "123.00",
            :payment_method => :bradesco
          })
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when :order_id is more than 50 characters" do
      expect {
        Braspag::Bill.new( {
            :order_id => "1" * 51,
            :amount => "12.00",
            :payment_method => :bradesco
          })
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when :customer_name is less than 1 character" do
      expect {
        Braspag::Bill.new( {
            :order_id => "102",
            :amount => "42.00",
            :payment_method => :bradesco,
            :customer_name => ""
          })
      }.to raise_error(Braspag::InvalidCustomerName)
    end

    it "should raise an error when :customer_name is more than 255 characters" do
      expect {
        Braspag::Bill.new( {
            :order_id => "112",
            :amount => "121.00",
            :payment_method => :bradesco,
            :customer_name => "A" * 256
          })
      }.to raise_error(Braspag::InvalidCustomerName)
    end

    it "should raise an error when :customer_id is less than 11 characters" do
      expect {
        Braspag::Bill.new( {
            :order_id => "23",
            :amount => "251.00",
            :payment_method => :bradesco,
            :customer_id => "2" * 10
          })
      }.to raise_error(Braspag::InvalidCustomerId)
    end

    it "should raise an error when :customer_id is more than 18 characters" do
      expect {
        Braspag::Bill.new( {
            :order_id => "90",
            :amount => "90.00",
            :payment_method => :bradesco,
            :customer_id => "3" * 19
          })
      }.to raise_error(Braspag::InvalidCustomerId)
    end

    it "should raise an error when :number is less than 1 character" do
      expect {
        Braspag::Bill.new( {
            :order_id => "900",
            :amount => "92.00",
            :payment_method => :bradesco,
            :number => ""
          })
      }.to raise_error(Braspag::InvalidNumber)
    end

    it "should raise an error when :number is more than 255 characters" do
      expect {
        Braspag::Bill.new( {
            :order_id => "91",
            :amount => "80.00",
            :payment_method => :bradesco,
            :number => "5" * 256
          })
      }.to raise_error(Braspag::InvalidNumber)
    end

    it "should raise an error when :instructions is less than 1 character" do
      expect {
        Braspag::Bill.new( {
            :order_id => "76",
            :amount => "50.00",
            :payment_method => :bradesco,
            :instructions => ""
          })
      }.to raise_error(Braspag::InvalidInstructions)
    end

    it "should raise an error when :instructions is more than 512 characters" do
      expect {
        Braspag::Bill.new( {
            :order_id => "65",
            :amount => "210.00",
            :payment_method => :bradesco,
            :instructions => "O" * 513
          })
      }.to raise_error(Braspag::InvalidInstructions)
    end

    it "should raise an error when :expiration_date is more or less than 8 characters" do
      expect {
        Braspag::Bill.new( {
            :order_id => "34",
            :amount => "245.00",
            :payment_method => :bradesco,
            :expiration_date => "1" * 7
          })
      }.to raise_error(Braspag::InvalidExpirationDate)

      expect {
        Braspag::Bill.new( {
            :order_id => "67",
            :amount => "321.00",
            :payment_method => :bradesco,
            :expiration_date => "2" * 9
          })
      }.to raise_error(Braspag::InvalidExpirationDate)
    end

    it "should accept :payment_method as Symbol Object and convert to relative String value" do
      (bill = Braspag::Bill.new( {
            :order_id => "67",
            :amount => "321.00",
            :payment_method => :itau,
            :expiration_date => Date.today + 2
          })
      ).should be_ok

      bill[:payment_method].should == :itau
    end

    it "should accept :expiration_date with Date Object" do
      Braspag::Bill.new( {
          :order_id => "67",
          :amount => "321.00",
          :payment_method => :bradesco,
          :expiration_date => Date.today + 2
        }).should be_ok
    end

    it "should accept :expiration_date with valid string date" do
      Braspag::Bill.new( {
          :order_id => "67",
          :amount => "321.00",
          :payment_method => :bradesco,
          :expiration_date => (Date.today + 2).strftime("%d/%m/%y")
        }).should be_ok
    end

    it "should accept string as :amount" do
      (bill = Braspag::Bill.new( {
            :order_id => "67",
            :amount => "54321.45",
            :payment_method => :bradesco,
            :expiration_date => (Date.today + 2).strftime("%d/%m/%y")
          })
      ).should be_ok

      bill[:amount].should == BigDecimal.new("54321.45")
    end

    it "should accept integer as :amount" do
      (bill = Braspag::Bill.new( {
            :order_id => "67",
            :amount => 123,
            :payment_method => :bradesco,
            :expiration_date => (Date.today + 2).strftime("%d/%m/%y")
          })
      ).should be_ok

      bill[:amount].should == BigDecimal.new("123.00")
    end

    it "should accept BigDecimal as :amount" do
      (bill = Braspag::Bill.new( {
            :order_id => "67",
            :amount => BigDecimal.new("123.45"),
            :payment_method => :bradesco,
            :expiration_date => (Date.today + 2).strftime("%d/%m/%y")
          })
      ).should be_ok

      bill[:amount].should == BigDecimal.new("123.45")
    end

    it "should accept integer as :amount" do
      (bill = Braspag::Bill.new( {
            :order_id => "67",
            :amount => 12345,
            :payment_method => :bradesco,
            :expiration_date => (Date.today + 2).strftime("%d/%m/%y")
          })
      ).should be_ok

      bill[:amount].should == BigDecimal.new("12345.00")
    end

  end

  describe ".generate" do
    context "with all data" do
      before do
        @tomorrow = (Time.now + 3600 * 24 * 2)
      
        data = {
          :order_id => Time.now.to_i.to_s,
          :amount => 3,
          :payment_method => :real,
          :number => "123123",
          :expiration_date => @tomorrow.strftime("%d/%m/%y")
        }

        @bill = Braspag::Bill.new( data)
        @response = @bill.generate
      end

      it "should return the bill number" do
        @response[:number].should == "123123"
      end

      it "should return the expiration date" do
        @response[:expiration_date].should be_kind_of Date
        @response[:expiration_date].strftime("%d/%m/%Y").should == @tomorrow.strftime("%d/%m/%Y")
      end
    end

    context "with minimum correct data" do
      before(:all) do
        data = {
          :order_id => Time.now.to_i.to_s,
          :amount => 1234.56,
          :payment_method => :real
        }
        @bill =  Braspag::Bill.new( data)
        @response = @bill.generate
      end

      it "should return a public url" do
        regexp = %r"https://homologacao\.pagador\.com\.br/pagador/reenvia\.asp\?Id_Transacao=[a-z0-9]{8}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{4}\-[a-z0-9]{12}"
        @response[:url].should match(regexp)
      end

      it "should return 0 (waiting payment) as the status" do
        @response[:status].should == "0"
      end

      it "should return 0 (success) as the return_code" do
        @response[:return_code].should == "0"
      end

      it "should return 3 as the amount" do
        @response[:amount].should == BigDecimal.new("1234.56")
      end

      it "should return the bill number" do
        @response[:number].should_not be_empty
      end

      it "should return the expiration date" do
        ten_days_after_today = (Time.now + 3600 * 24 * 10)
        
        @response[:expiration_date].should be_kind_of Date
        @response[:expiration_date].strftime("%d/%m/%Y").should == ten_days_after_today.strftime("%d/%m/%Y")
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

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new( {
              :order_id => 1,
              :amount => 3,
              :payment_method => :hsbc
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

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new( {
              :number => "A" * 50,
              :order_id => "x",
              :amount => 3,
              :payment_method => :hsbc
            })
          bill.generate
        }.to raise_error(Braspag::InvalidStringFormat)

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

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new( {
              :order_id => 1,
              :amount => "0000",
              :payment_method => :hsbc
            })
          bill.generate
        }.to raise_error(Braspag::InvalidPaymentMethod)

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

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new( {
              :order_id => 1,
              :amount => -33,
              :payment_method => :hsbc
            })
          bill.generate
        }.to raise_error(Braspag::InvalidAmount)

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

        FakeWeb.register_uri(:post, "#{braspag_url}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => xml)

        expect {
          bill = Braspag::Bill.new( {
              :order_id => 1,
              :amount => 3,
              :payment_method => :real
            })
          bill.generate
        }.to raise_error(Braspag::UnknownError)

        FakeWeb.clean_registry
      end
    end

    context "#payment_method_from_id" do
      it 'Credit card amex' do
        Braspag::Bill::payment_method_from_id("06").should == :bradesco
        Braspag::Bill::payment_method_from_id("06").should be_kind_of Symbol
      end
    end
  end
end
