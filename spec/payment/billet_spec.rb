# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}

  context ".generate_billet" do
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


    it "should call gateway with correct data" do
      Braspag::Poster.any_instance.should_receive(:do_post).with(:generate_billet, {
            "merchantId"       => "#{merchant_id}", 
            "orderId"          => "#{order.id}", 
            "customerName"     => "#{customer.name}", 
            "customerIdNumber" => "#{customer.document}",
            "amount"           => "100,00", 
            "paymentMethod"    => 6, 
            "boletoNumber"     => "#{billet.id}", 
            "expirationDate"   => "01/01/12", 
            "instructions"     => "#{billet.instructions}", 
            "emails"           => "#{customer.email}"
          }
        ).and_return(mock(:body => valid_xml))
      connection.generate_billet(order, billet)
    end
    
    it "should populate data" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => valid_xml))
      connection.generate_billet(order, billet)

      billet.url.should eq('https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=722934be-6756-477a-87ab-42115ee1424d')
      order.gateway_return_code.should eq('0')
      order.gateway_status.should eq('0')
      order.gateway_amount.should eq(3.00)
    end
    
    it "should return response object" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => valid_xml))
      response = connection.generate_billet(order, billet)
      
      response.success?.should be(true)
    end

    it "should return error in response" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => invalid_xml))
      response = connection.generate_billet(order, billet)
      
      response.success?.should be(false)
      response.message.should eq('Invalid merchantId')
      response.params.should eq({"url"=>nil, "amount"=>nil, "number"=>nil, "expiration_date"=>nil, "return_code"=>"1", "status"=>nil, "message"=>"Invalid merchantId"})
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
end

