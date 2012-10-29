require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
  
  context ".purchase" do
    it "should return authorize when authroize response failed" do
      auth = mock(:success? => false)
      connection.stub(:authorize).and_return(auth)
      connection.purchase(mock, mock).should eq(auth)
    end
    
    it "should return capture when authorize response success" do
      cap = mock(:success? => true)
      connection.stub(:authorize).and_return(mock(:success? => true))
      connection.stub(:capture).and_return(cap)
      connection.purchase(mock, mock).should eq(cap)
    end
  end
  
  context ".authorize" do
    it "should return response" do
      authorize = {
        :status  => "2",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(authorize)
      
      response = connection.authorize(mock, mock)
      
      response.success?.should eq(false)
      response.message.should eq(authorize[:message])
      response.authorization.should eq(authorize[:number])
      response.params.should eq({"status"=>"2", "message"=>"BLA", "number"=>"12345"})
      response.test.should eq(true)
    end

    it "should return success when status is zero" do
      authorize = {
        :status  => "0",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(authorize)
      
      response = connection.authorize(mock, mock)
      
      response.success?.should eq(true)
    end
    
    it "should return success when status is one" do
      authorize = {
        :status  => "1",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(authorize)
      
      response = connection.authorize(mock, mock)
      
      response.success?.should eq(true)
    end
  end
  
  context ".capture" do
    it "should return response" do
      capture = {
        :status  => "1",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(capture)
      
      response = connection.capture(mock)
      
      response.success?.should eq(false)
      response.message.should eq(capture[:message])
      response.authorization.should eq(capture[:number])
      response.params.should eq({"status"=>"1", "message"=>"BLA", "number"=>"12345"})
      response.test.should eq(true)
    end

    it "should return success when status is zero" do
      capture = {
        :status  => "0",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(capture)
      
      response = connection.capture(mock)
      
      response.success?.should eq(true)
    end
  end
  
  context ".void" do
    it "should return response" do
      void = {
        :status  => "1",
        :message => "BLA"
      }
      
      connection.should_receive(:post).and_return(void)
      
      response = connection.void(mock)
      
      response.success?.should eq(false)
      response.message.should eq(void[:message])
      response.params.should eq({"status"=>"1", "message"=>"BLA"})
      response.test.should eq(true)
    end

    it "should return success when status is zero" do
      void = {
        :status  => "0",
        :message => "BLA"
      }
      
      connection.should_receive(:post).and_return(void)
      
      response = connection.void(mock)
      
      response.success?.should eq(true)
    end
  end
end

describe Braspag::CreditCard do
  
  [:purchase, :authorize, :archive].each do |context_type|
    context "on #{context_type}" do
      it "should validate minimum 1 length of holder_name" do
        subject.holder_name = ''
        subject.valid?(context_type)
        subject.errors.messages[:holder_name].should include("is too short (minimum is 1 characters)")
      end

      it "should validate maximum 100 length of holder_name" do
        subject.holder_name = '*' * 110
        subject.valid?(context_type)
        subject.errors.messages[:holder_name].should include("is too long (maximum is 100 characters)")
      end

      it "should not allow blank for number" do
        subject.number = ''
        subject.valid?(context_type)
        subject.errors.messages[:number].should include("can't be blank")
      end

      it "should not allow blank for month" do
        subject.month = ''
        subject.valid?(context_type)
        subject.errors.messages[:month].should include("can't be blank")
      end

      it "should not allow blank for year" do
        subject.year = ''
        subject.valid?(context_type)
        subject.errors.messages[:year].should include("can't be blank")
      end
      
      it "should not allow invalid date for month & year" do
        subject.month = "14"
        subject.year = "2012"
        subject.valid?(context_type)
        subject.errors.messages[:month].should include("invalid date")
        subject.errors.messages[:year].should include("invalid date")
      end

      it "should allow valid date for month & year" do
        subject.month = "09"
        subject.year = "12"
        subject.valid?(context_type)
        subject.errors.messages[:month].should be(nil)
        subject.errors.messages[:year].should be(nil)
      end

      it "should allow valid date for month & year" do
        subject.month = 12
        subject.year = 2014
        subject.valid?(context_type)
        subject.errors.messages[:month].should be(nil)
        subject.errors.messages[:year].should be(nil)
      end
    end
  end
  
  [:purchase, :authorize, :recurrency].each do |context_type|
    context "on #{context_type}" do
      it "should validate minimum 1 length of verification_value" do
        subject.verification_value = ''
        subject.valid?(context_type)
        subject.errors.messages[:verification_value].should include("is too short (minimum is 1 characters)")
      end

      it "should validate maximum 4 length of verification_value" do
        subject.verification_value = '*' * 5
        subject.valid?(context_type)
        subject.errors.messages[:verification_value].should include("is too long (maximum is 4 characters)")
      end
    end
  end
  
  [:get_recurrency, :recurrency].each do |context_type|
    context "on #{context_type}" do
      it "should validate length of id" do
        subject.id = '*' * 37
        subject.valid?(context_type)
        subject.errors.messages[:id].should include("is the wrong length (should be 36 characters)")
      end
    end
  end
  
  let(:customer) do
    Braspag::Customer.new(:name => "W" * 21)
  end

  let(:order) do
    Braspag::Order.new(
      :id                => "um order id",
      :amount            => 1000.00,
      :payment_method    => Braspag::PAYMENT_METHOD[:redecard],
      :installments      => 1,
      :installments_type => Braspag::INTEREST[:no],
      :customer          => customer
    )
  end

  let(:credit_card) do
    Braspag::CreditCard.new(
      :holder_name        => "Joao Maria Souza",
      :number             => "9" * 10,
      :month              => "10",
      :year               => "12",
      :verification_value => "123"
    )
  end
  
  context "on authorize credit card" do
    let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
    let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}

    let(:valid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                     xmlns="https://www.pagador.com.br/webservice/pagador">
        <amount>1.000,00</amount>
        <message>Transaction Successful</message>
        <authorisationNumber>733610</authorisationNumber>
        <returnCode>0</returnCode>
        <status>1</status>
        <transactionId>01231234</transactionId>
      </PagadorReturn>
      EOXML
    end

    it "should convert objects to hash" do
      Braspag::CreditCard.to_authorize(connection, order, credit_card).should eq({
        "merchantId"     => "#{merchant_id}", 
        "orderId"        => "#{order.id}", 
        "customerName"   => "#{customer.name}", 
        "amount"         => "1000,00", 
        "paymentMethod"  => 20, 
        "holder"         => "#{credit_card.holder_name}", 
        "cardNumber"     => "#{credit_card.number}", 
        "expiration"     => "10/12", 
        "securityCode"   => "123", 
        "numberPayments" => order.installments, 
        "typePayment"    => order.installments_type
      })
    end
    
    it "should populate data" do
      resp = Braspag::CreditCard.from_authorize(connection, order, credit_card, mock(:body => valid_xml))
      
      order.gateway_authorization.should eq('733610')
      order.gateway_id.should eq('01231234')
      order.gateway_return_code.should eq('0')
      order.gateway_status.should eq('1')
      order.gateway_message.should eq('Transaction Successful')
      order.gateway_amount.should eq(1000.00)
      
      resp.should eq({
        :amount=>"1.000,00", 
        :number=>"733610",
        :message=>"Transaction Successful",
        :return_code=>"0",
        :status=>"1",
        :transaction_id=>"01231234"})
    end
  end
  
  context "on capture credit card" do
    let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
    let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
    
    let(:valid_xml) do
          <<-EOXML
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
    end
    
    it "should convert objects to hash" do
      Braspag::CreditCard.to_capture(connection, order).should eq({
        "merchantId"     => "#{merchant_id}", 
        "orderId"        => "#{order.id}"
      })
    end
    
    it "should populate data" do
      resp = Braspag::CreditCard.from_capture(connection, order, mock(:body => valid_xml))
      
      order.gateway_capture_return_code.should eq('0')
      order.gateway_capture_status.should eq('0')
      order.gateway_capture_message.should eq('Approved')
      order.gateway_capture_amount.should eq(2.00)

      
      resp.should eq({
        :amount=>"2", 
        :message=>"Approved", 
        :return_code=>"0", 
        :status=>"0", 
        :transaction_id=>nil
      })
    end
  end
  
  context "on void credit card" do
    let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
    let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
    
    let(:valid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                     xmlns="https://www.pagador.com.br/webservice/pagador">
       <orderId>1234</orderId>
       <transactionId>0</transactionId>
       <amount>100</amount>
       <message>Approved</message>
       <returnCode>0</returnCode>
       <status>0</status>
      </PagadorReturn>
      EOXML
    end
    
    it "should convert objects to hash" do
      Braspag::CreditCard.to_void(connection, order).should eq({
        "merchantId"     => "#{merchant_id}", 
        "order"        => "#{order.id}"
      })
    end
    
    it "should populate data" do
      resp = Braspag::CreditCard.from_void(connection, order, mock(:body => valid_xml))
      
      order.gateway_void_return_code.should eq('0')
      order.gateway_void_status.should eq('0')
      order.gateway_void_message.should eq('Approved')
      order.gateway_void_amount.should eq(100.00)
      
      resp.should eq({:order_id=>"1234", :amount=>"100", :message=>"Approved", :return_code=>"0", :status=>"0", :transaction_id=>"0"})
    end
  end
end
