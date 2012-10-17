require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "um id qualquer" }

  pending ".authorize" do
    let(:params) do
      {
        :order_id => "um order id",
        :customer_name => "W" * 21,
        :amount => "100.00",
        :payment_method => :redecard,
        :holder => "Joao Maria Souza",
        :card_number => "9" * 10,
        :expiration => "10/12",
        :security_code => "123",
        :number_payments => 1,
        :type => 0
      }
    end

    let(:params_with_merchant_id) do
      params.merge!(:merchant_id => merchant_id)
    end

    let(:authorize_url) { "http://braspag/bla" }

    before do
      @connection.should_receive(:merchant_id)

      Braspag::CreditCard.should_receive(:authorize_url)
                         .and_return(authorize_url)

      Braspag::CreditCard.should_receive(:check_params)
                         .and_return(true)
    end

    context "with invalid params"

    context "with valid params" do
      let(:valid_xml) do
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <PagadorReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns="https://www.pagador.com.br/webservice/pagador">
          <amount>5</amount>
          <message>Transaction Successful</message>
          <authorisationNumber>733610</authorisationNumber>
          <returnCode>7</returnCode>
          <status>2</status>
          <transactionId>0</transactionId>
        </PagadorReturn>
        EOXML
      end

      let(:request) { OpenStruct.new :url => authorize_url }

      before do
        Braspag::Connection.instance.should_receive(:homologation?)
        ::HTTPI::Request.should_receive(:new).with(authorize_url).and_return(request)
        ::HTTPI.should_receive(:post).with(request).and_return(mock(:body => valid_xml))
      end

      it "should return a Hash" do
        response = Braspag::CreditCard.authorize(params)
        response.should be_kind_of Hash
        response.should == {
          :amount => "5",
          :message => "Transaction Successful",
          :number => "733610",
          :return_code => "7",
          :status => "2",
          :transaction_id => "0"
        }
      end

      it "should post transation info" do
        Braspag::CreditCard.authorize(params)
        request.body.should == {"merchantId"=>"um id qualquer", "order"=>"", "orderId"=>"um order id", "customerName"=>"WWWWWWWWWWWWWWWWWWWWW", "amount"=>"100,00", "paymentMethod"=>20, "holder"=>"Joao Maria Souza", "cardNumber"=>"9999999999", "expiration"=>"10/12", "securityCode"=>"123", "numberPayments"=>1, "typePayment"=>0}
      end
    end
  end

  pending ".capture" do
    let(:capture_url) { "http://foo.bar/bar/baz" }
    let(:order_id) { "um id qualquer" }

    before do
      @connection.should_receive(:merchant_id)
    end

    context "invalid order id" do
      it "should raise an error" do
        Braspag::CreditCard.should_receive(:valid_order_id?)
                           .with(order_id)
                           .and_return(false)

        expect {
          Braspag::CreditCard.capture(order_id)
        }.to raise_error(Braspag::InvalidOrderId)
      end
    end

    context "valid order id" do
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

      let(:request) { OpenStruct.new :url => capture_url }

      before do
        Braspag::CreditCard.should_receive(:capture_url)
                           .and_return(capture_url)

        ::HTTPI::Request.should_receive(:new)
                        .with(capture_url)
                        .and_return(request)

        ::HTTPI.should_receive(:post)
               .with(request)
               .and_return(mock(:body => valid_xml))
      end

      it "should return a Hash" do
        response = Braspag::CreditCard.capture("order id qualquer")
        response.should be_kind_of Hash
        response.should == {
          :amount => "2",
          :number => nil,
          :message => "Approved",
          :return_code => "0",
          :status => "0",
          :transaction_id => nil
        }
      end

      it "should post capture info" do
        Braspag::CreditCard.capture("order id qualquer")
        request.body.should == {"orderId"=>"order id qualquer", "merchantId"=>"um id qualquer"}
      end
    end
  end

  pending ".void" do
    let(:cancellation_url) { "http://foo.bar/bar/baz" }
    let(:order_id) { "um id qualquer" }

    before do
      @connection.should_receive(:merchant_id)
    end

    context "invalid order id" do
      it "should raise an error" do
        Braspag::CreditCard.should_receive(:valid_order_id?)
                           .with(order_id)
                           .and_return(false)

        expect {
          Braspag::CreditCard.void(order_id)
        }.to raise_error(Braspag::InvalidOrderId)
      end
    end

    context "valid order id" do
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

      let(:request) { OpenStruct.new :url => cancellation_url }

      before do
        Braspag::CreditCard.should_receive(:cancellation_url)
                           .and_return(cancellation_url)

        ::HTTPI::Request.should_receive(:new).with(cancellation_url).and_return(request)
        ::HTTPI.should_receive(:post).with(request).and_return(mock(:body => valid_xml))
      end

      it "should return a Hash" do
        response = Braspag::CreditCard.void("order id qualquer")
        response.should be_kind_of Hash
        response.should == {
          :amount => "2",
          :number => nil,
          :message => "Approved",
          :return_code => "0",
          :status => "0",
          :transaction_id => nil
        }
      end

      it "should post void info" do
        Braspag::CreditCard.void("order id qualquer")
        request.body.should == {"order"=>"order id qualquer", "merchantId"=>"um id qualquer"}
      end
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
  
  context "validate for purchase" do
    subject { Braspag::CreditCard }
    
    it { should validate_presence_of(:holder_name).on(:purchase) }
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:month) }
    it { should validate_presence_of(:year) }
  end
  
  pending "validate for authorize" do
    it { should validate_presence_of(:holder_name) }
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:month) }
    it { should validate_presence_of(:year) }
  end
  
  pending "validate for archive" do
    it { should validate_presence_of(:holder_name) }
    it { should validate_presence_of(:number) }
    it { should validate_presence_of(:month) }
    it { should validate_presence_of(:year) }
  end

  context "validate for recurrency" do
  end
  
  context "validate for get" do
  end
  
  context "validate for void" do
  end
  
  pending ".check_params" do
    let(:params) do
      {
        :order_id => 12345,
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
    end

    [:order_id, :amount, :payment_method, :customer_name, :holder, :card_number, :expiration,
      :security_code, :number_payments, :type].each do |param|
      it "should raise an error when #{param} is not present" do
        expect {
          params[param] = nil
          Braspag::CreditCard.check_params(params)
        }.to raise_error Braspag::IncompleteParams
      end
    end

    it "should raise an error when order_id is not valid" do
      Braspag::CreditCard.should_receive(:valid_order_id?)
                         .with(params[:order_id])
                         .and_return(false)

      expect {
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidOrderId
    end

    it "should raise an error when payment_method is not invalid" do
      expect {
        params[:payment_method] = "non ecziste"
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidPaymentMethod
    end

    it "should raise an error when customer_name is greater than 255 chars" do
      expect {
        params[:customer_name] = "b" * 256
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidCustomerName
    end

    it "should raise an error when holder is greater than 100 chars" do
      expect {
        params[:holder] = "r" * 101
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidHolder
    end

    it "should raise an error when expiration is not in a valid format" do
      expect {
        params[:expiration] = "2011/19/19"
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidExpirationDate

      expect {
        params[:expiration] = "12/2012"
        Braspag::CreditCard.check_params(params)
      }.to_not raise_error Braspag::InvalidExpirationDate

      expect {
        params[:expiration] = "12/12"
        Braspag::CreditCard.check_params(params)
      }.to_not raise_error Braspag::InvalidExpirationDate
    end

    it "should raise an error when security code is greater than 4 chars" do
      expect {
        params[:security_code] = "12345"
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidSecurityCode

      expect {
        params[:security_code] = ""
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidSecurityCode
    end

    it "should raise an error when number_payments is greater than 99" do
      expect {
        params[:number_payments] = 100
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidNumberPayments

      expect {
        params[:number_payments] = 0
        Braspag::CreditCard.check_params(params)
      }.to raise_error Braspag::InvalidNumberPayments
    end
  end
  
end
