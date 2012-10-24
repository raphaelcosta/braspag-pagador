require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
  
  context ".authorize" do
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
    
    let(:invalid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
                     xmlns="https://www.pagador.com.br/webservice/pagador">
        <amount>100</amount>
        <authorisationNumber>null</authorisationNumber>
        <message>Payment Server detected an error</message>
        <returnCode>7</returnCode>
        <status>2</status>
        <transactionId>0</transactionId>
      </PagadorReturn>
      EOXML
    end


    it "should call gateway with correct data" do
      Braspag::Poster.any_instance.should_receive(:do_post).with(:authorize, {
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
          }
        ).and_return(mock(:body => valid_xml))
      connection.authorize(order, credit_card)
    end
    
    it "should populate data" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => valid_xml))
      connection.authorize(order, credit_card)
      
      order.gateway_authorization.should eq('733610')
      order.gateway_id.should eq('01231234')
      order.gateway_return_code.should eq('0')
      order.gateway_status.should eq('1')
      order.gateway_message.should eq('Transaction Successful')
      order.gateway_amount.should eq(1000.00)
    end
    
    it "should return response object" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => valid_xml))
      response = connection.authorize(order, credit_card)
      
      response.success?.should be(true)
      response.message.should eq('Transaction Successful')
    end

    it "should return error in response" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => invalid_xml))
      response = connection.authorize(order, credit_card)
      
      response.success?.should be(false)
      response.message.should eq('Payment Server detected an error')
      response.params.should eq({"amount"=>"100", "number"=>"null", "message"=>"Payment Server detected an error", "return_code"=>"7", "status"=>"2", "transaction_id"=>"0"})
    end
  end
  
  context ".capture" do
    let(:order) do
      Braspag::Order.new(
        :id => "um order id"
      )
    end
    
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
    
    let(:invalid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
                     xmlns="https://www.pagador.com.br/webservice/pagador">
        <amount>100</amount>
        <message>Payment Server detected an error</message>
        <returnCode>7</returnCode>
        <status>2</status>
        <transactionId>0</transactionId>
      </PagadorReturn>
      EOXML
    end


    it "should call gateway with correct data" do
      Braspag::Poster.any_instance.should_receive(:do_post).with(:capture, {
            "merchantId"     => "#{merchant_id}", 
            "orderId"        => "#{order.id}"
          }
        ).and_return(mock(:body => valid_xml))
      connection.capture(order)
    end
    
    it "should populate data" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => valid_xml))
      connection.capture(order)
      
      order.gateway_capture_return_code.should eq('0')
      order.gateway_capture_status.should eq('0')
      order.gateway_capture_message.should eq('Approved')
      order.gateway_capture_amount.should eq(2.00)
    end
    
    it "should return response object" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => valid_xml))
      response = connection.capture(order)
      
      response.success?.should be(true)
      response.message.should eq('Approved')
    end

    it "should return error in response" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => invalid_xml))
      response = connection.capture(order)
      
      response.success?.should be(false)
      response.message.should eq('Payment Server detected an error')
      response.params.should eq({"amount"=>"100", "message"=>"Payment Server detected an error", "return_code"=>"7", "status"=>"2", "transaction_id"=>"0"})
    end
  end
  
  context ".void" do
    let(:order) do
      Braspag::Order.new(
        :id => "um order id"
      )
    end
    
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
    
    let(:invalid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema" 
                     xmlns="https://www.pagador.com.br/webservice/pagador">
        <orderId>1234</orderId>
        <amount>100</amount>
        <message>Payment Server detected an error</message>
        <returnCode>7</returnCode>
        <status>2</status>
        <transactionId>0</transactionId>
      </PagadorReturn>
      EOXML
    end


    it "should call gateway with correct data" do
      Braspag::Poster.any_instance.should_receive(:do_post).with(:void, {
            "merchantId"     => "#{merchant_id}", 
            "order"        => "#{order.id}"
          }
        ).and_return(mock(:body => valid_xml))
      connection.void(order)
    end
    
    it "should populate data" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => valid_xml))
      connection.void(order)
      
      order.gateway_void_return_code.should eq('0')
      order.gateway_void_status.should eq('0')
      order.gateway_void_message.should eq('Approved')
      order.gateway_void_amount.should eq(100.00)
    end
    
    it "should return response object" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => valid_xml))
      response = connection.void(order)
      
      response.success?.should be(true)
      response.message.should eq('Approved')
    end

    it "should return error in response" do
      Braspag::Poster.any_instance.should_receive(:do_post).and_return(mock(:body => invalid_xml))
      response = connection.void(order)
      
      response.success?.should be(false)
      response.message.should eq('Payment Server detected an error')
      response.params.should eq({"order_id"=>"1234", "amount"=>"100", "message"=>"Payment Server detected an error", "return_code"=>"7", "status"=>"2", "transaction_id"=>"0"})
    end
  end

  pending ".save" do
    let(:params) do
      {
        :customer_name => "W" * 21,
        :holder =>  "Joao Maria Souza",
        :card_number => "9" * 10,
        :expiration => "10/12",
        :order_id => "um order id",
        :request_id => "00000000-0000-0000-0000-000000000044"
      }
    end

    let(:params_with_merchant_id) do
      params.merge!(:merchant_id => merchant_id)
    end

    let(:save_protected_card_url) { "http://braspag.com/bla" }

    let(:savon_double) { double('Savon') }

    before do
      @connection.should_receive(:merchant_id)
    end

    context "with valid params" do
      let(:valid_hash) do
        {
          :save_credit_card_response => {
            :save_credit_card_result => {
              :just_click_key => 'SAVE-PROTECTED-CARD-TOKEN',
              :success => true
            }
          }
        }
      end

      let(:response) do
        double('Response', :to_hash => valid_hash)
      end

      before do
        Braspag::ProtectedCreditCard.should_receive(:save_protected_card_url)
        Braspag::ProtectedCreditCard.should_receive(:check_protected_card_params)
                           .and_return(true)
        Savon::Client.should_receive(:new).and_return(savon_double)
        savon_double.should_receive(:request).and_return(response)

        @response = Braspag::ProtectedCreditCard.save(params)
      end

      it "should return a Hash" do
        @response.should be_kind_of Hash
        @response.should == {
          :just_click_key => "SAVE-PROTECTED-CARD-TOKEN",
          :success => true
        }
      end
    end

    context "with invalid params" do
      let(:invalid_hash) do
        {
          :save_credit_card_response => {
            :save_credit_card_result => {
              :just_click_key => nil,
              :success => false
            }
          }
        }
      end

      let(:response) do
        double('Response', :to_hash => invalid_hash)
      end

      before do
        Braspag::ProtectedCreditCard.should_receive(:check_protected_card_params)
                            .and_return(true)
        Braspag::ProtectedCreditCard.should_receive(:save_protected_card_url)
                            .and_return(save_protected_card_url)
        Savon::Client.should_receive(:new).and_return(savon_double)
        savon_double.should_receive(:request).and_return(response)

        @response = Braspag::ProtectedCreditCard.save(params)
      end

      it "should return a Hash" do
        @response.should be_kind_of Hash
        @response.should == {
          :just_click_key => nil,
          :success => false
        }
      end
    end
  end

  pending ".get" do
    let(:get_protected_card_url) { "http://braspag/bla" }

    let(:invalid_xml) do
      <<-EOXML
      <CartaoProtegidoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <CardHolder>Joao Maria Souza</CardHolder>
        <CardNumber></CardNumber>
        <CardExpiration>10/12</CardExpiration>
        <MaskedCardNumber>******9999</MaskedCardNumber>
      </CartaoProtegidoReturn>
      EOXML
    end

    let(:valid_xml) do
      <<-EOXML
      <CartaoProtegidoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <CardHolder>Joao Maria Souza</CardHolder>
        <CardNumber>9999999999</CardNumber>
        <CardExpiration>10/12</CardExpiration>
        <MaskedCardNumber>******9999</MaskedCardNumber>
      </CartaoProtegidoReturn>
      EOXML
    end

    it "should raise an error when just click key is not valid" do
      Braspag::ProtectedCreditCard.should_receive(:valid_just_click_key?)
                         .with("bla")
                         .and_return(false)

      expect {
        Braspag::ProtectedCreditCard.get "bla"
      }.to raise_error(Braspag::InvalidJustClickKey)
    end

    it "should raise an error when Braspag returned an invalid xml as response" do
      FakeWeb.register_uri(:post, get_protected_card_url, :body => invalid_xml)

      Braspag::ProtectedCreditCard.should_receive(:get_protected_card_url)
                         .and_return(get_protected_card_url)

      expect {
        Braspag::ProtectedCreditCard.get("b0b0b0b0-bbbb-4d4d-bd27-f1f1f1ededed")
      }.to raise_error(Braspag::UnknownError)
    end

    it "should return a Hash when Braspag returned a valid xml as response" do
      FakeWeb.register_uri(:post, get_protected_card_url, :body => valid_xml)

      Braspag::ProtectedCreditCard.should_receive(:get_protected_card_url)
                         .and_return(get_protected_card_url)

      response = Braspag::ProtectedCreditCard.get("b0b0b0b0-bbbb-4d4d-bd27-f1f1f1ededed")
      response.should be_kind_of Hash

      response.should == {
        :holder => "Joao Maria Souza",
        :expiration => "10/12",
        :card_number => "9" * 10,
        :masked_card_number => "*" * 6 + "9" * 4
      }
    end

  end

  pending ".just_click_shop" do
    context "body" do
      let(:params) { {
        :request_id => "123",
        :customer_name => "Joao Silva",
        :order_id => "999",
        :amount => 10.50,
        :payment_method => :redecard,
        :number_installments => 3,
        :payment_type => "test",
        :just_click_key => "key",
        :security_code => "123"
      } }

      class SavonClientTest
        attr_accessor :response
        attr_reader :method

        def request(web, method, &block)
          @method = method
          instance_eval &block

          @response
        end

        def soap
          @soap ||= OpenStruct.new
        end
      end

      before :each do
        @savon_client_test = SavonClientTest.new
        @savon_client_test.response = {:just_click_shop_response => {}}
        Savon::Client.stub(:new).with('https://www.cartaoprotegido.com.br/Services/TestEnvironment/CartaoProtegido.asmx?wsdl').and_return(@savon_client_test)
      end

      after :each do
        Savon::Client.unstub(:new)
      end

      it "should have RequestId" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['RequestId'].should eq '123'
      end

      it "should have MerchantKey" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['MerchantKey'].should eq 'um id qualquer'
      end

      it "should have CustomerName" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['CustomerName'].should eq 'Joao Silva'
      end

      it "should have OrderId" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['OrderId'].should eq '999'
      end

      it "should have Amount" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['Amount'].should eq 10.50
      end

      it "should have PaymentMethod" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['PaymentMethod'].should eq 20
      end

      it "should have PaymentType" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['PaymentType'].should eq 'test'
      end

      it "should have NumberInstallments" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['NumberInstallments'].should eq 3
      end

      it "should have JustClickKey" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['JustClickKey'].should eq 'key'
      end

      it "should have SecurityCode" do
        described_class.just_click_shop(params)
        @savon_client_test.soap.body['justClickShopRequestWS']['SecurityCode'].should eq '123'
      end
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
  
end
