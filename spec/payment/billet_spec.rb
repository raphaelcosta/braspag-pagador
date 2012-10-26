# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}

  context ".generate_billet" do
    it "should return response" do
      generate_billet = {
        :status  => "1",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(generate_billet)
      
      response = connection.generate_billet(mock, mock)
      
      response.success?.should eq(false)
      response.message.should eq(generate_billet[:message])
      response.authorization.should eq(generate_billet[:number])
      response.params.should eq({"status"=>"1", "message"=>"BLA", "number"=>"12345"})
      response.test.should eq(true)
    end

    it "should return success when status is zero" do
      generate_billet = {
        :status  => "0",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(generate_billet)
      
      response = connection.generate_billet(mock, mock)
      
      response.success?.should eq(true)
    end
  end
end

describe Braspag::Billet do
  context "on generate" do
    it "should allow blank for id" do
      subject.id = ''
      subject.valid?(:generate)
      subject.errors.messages[:id].should be(nil)
    end
    
    it "should validate maximum 255 length of id" do
      subject.id = '*' * 260
      subject.valid?(:generate)
      subject.errors.messages[:id].should include("is too long (maximum is 255 characters)")
    end
    
    it "should allow blank for instructions" do
      subject.instructions = ''
      subject.valid?(:generate)
      subject.errors.messages[:instructions].should be(nil)
    end
    
    it "should validate maximum 512 length of instructions" do
      subject.instructions = '*' * 520
      subject.valid?(:generate)
      subject.errors.messages[:instructions].should include("is too long (maximum is 512 characters)")
    end
    
    it "should not allow blank for due_date_on" do
      subject.due_date_on = ''
      subject.valid?(:generate)
      subject.errors.messages[:due_date_on].should include("can't be blank")
    end
    
    it "should not allow invalid date for due_date_on" do
      subject.due_date_on = '12345'
      subject.valid?(:generate)
      subject.errors.messages[:due_date_on].should include("invalid date")
    end
    
    it "should allow date for due_date_on" do
      subject.due_date_on = Date.parse('07/03/1988')
      subject.valid?(:generate)
      subject.errors.messages[:due_date_on].should be(nil)
    end
  end
  
  context "on generate billet" do
    let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
    let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
    
    let(:customer) do
      Braspag::Customer.new(
        :document     => '21473696240', # (OPTIONAL)
        :name   => 'Bob Dela Bobsen',
        :email  => 'bob@mailinator.com' # send email to consumer (OPTIONAL)
      )
    end

    let(:order) do
      Braspag::Order.new(
        :id                => "um order id",
        :amount            => 100.00,
        :payment_method    => Braspag::PAYMENT_METHOD[:billet_bradesco],
        :customer          => customer
      )
    end

    let(:billet) do
      Braspag::Billet.new(
        :id           => '123456',
        :instructions => 'does not accepted after due date', 
        :due_date_on  => Date.parse('2012-01-01')
      )
    end
    
    let(:url) { "https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=722934be-6756-477a-87ab-42115ee1424d" }
    
    let(:valid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <PagadorBoletoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                           xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                           xmlns="https://www.pagador.com.br/webservice/pagador">
        <amount>3.00</amount>
        <boletoNumber>123123</boletoNumber>
        <expirationDate>2012-01-08T00:00:00</expirationDate>
        <url>https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=722934be-6756-477a-87ab-42115ee1424d</url>
        <returnCode>0</returnCode>
        <status>0</status>
      </PagadorBoletoReturn>
      EOXML
    end
    
    let(:invalid_xml) do
      <<-EOXML
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
    end

    it "should convert objects to hash" do
      Braspag::Billet.to_generate_billet(connection, order, billet).should eq({
          "merchantId"       => connection.merchant_id,
          "boletoNumber"     => billet.id.to_s,
          "instructions"     => billet.instructions.to_s,
          "expirationDate"   => billet.due_date_on.strftime("%d/%m/%y"),
          "customerName"     => order.customer.name.to_s,
          "customerIdNumber" => order.customer.document.to_s,
          "emails"           => order.customer.email.to_s,
          "orderId"          => order.id.to_s,
          "amount"           => Braspag::Converter::decimal_to_string(order.amount),
          "paymentMethod"    => order.payment_method
      })
    end
    
    
    it "should convert response from xml" do
      resp = Braspag::Billet.from_generate_billet(connection, order, billet, mock(:body => valid_xml))
      
      billet.url.should eq(url)
      order.gateway_return_code.should eq('0')
      order.gateway_status.should eq('0')
      order.gateway_amount.should eq(3.00)
      
      resp.should eq({
        :url             => url, 
        :amount          => "3.00", 
        :number          => "123123", 
        :expiration_date => Date.parse('2012-01-08'), 
        :return_code     => "0", 
        :status          => "0", 
        :message         => nil
      })
    end
    
    it "should convert response from xml with invalid date" do
      resp = Braspag::Billet.from_generate_billet(connection, order, billet, mock(:body => invalid_xml))
      
      billet.url.should eq(nil)
      order.gateway_return_code.should eq('1')
      order.gateway_status.should eq(nil)
      order.gateway_amount.should eq(nil)
      
      resp.should eq({
        :url             => nil, 
        :amount          => nil, 
        :number          => nil, 
        :expiration_date => nil,
        :return_code     => "1", 
        :status          => nil, 
        :message         => "Invalid merchantId"
      })
    end
  end
end

