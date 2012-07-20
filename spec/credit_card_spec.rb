require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::CreditCard do
  let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
  let(:braspag_production_url) { "https://transaction.pagador.com.br" }
  let(:braspag_homologation_protected_card_url) { "https://cartaoprotegido.braspag.com.br" }
  let(:braspag_production_protected_card_url) { "https://www.cartaoprotegido.com.br" }
  let(:merchant_id) { "um id qualquer" }

  before do
    @connection = mock(:merchant_id => merchant_id)
    Braspag::Connection.stub(:instance => @connection)
  end

  describe ".authorize" do
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

      before do
        FakeWeb.register_uri(:post, authorize_url, :body => valid_xml)
        @response = Braspag::CreditCard.authorize(params)
      end

      it "should return a Hash" do
        @response.should be_kind_of Hash
        @response.should == {
          :amount => "5",
          :message => "Transaction Successful",
          :number => "733610",
          :return_code => "7",
          :status => "2",
          :transaction_id => "0"
        }
      end
    end
  end

  describe ".capture" do
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

      before do
        Braspag::CreditCard.should_receive(:capture_url)
                           .and_return(capture_url)

        FakeWeb.register_uri(:post, capture_url, :body => valid_xml)
        @response = Braspag::CreditCard.capture("order id qualquer")
      end

      it "should return a Hash" do
        @response.should be_kind_of Hash
        @response.should == {
          :amount => "2",
          :number => nil,
          :message => "Approved",
          :return_code => "0",
          :status => "0",
          :transaction_id => nil
        }
      end
    end
  end

  describe ".void" do
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

      before do
        Braspag::CreditCard.should_receive(:cancellation_url)
                           .and_return(cancellation_url)

        FakeWeb.register_uri(:post, cancellation_url, :body => valid_xml)
        @response = Braspag::CreditCard.void("order id qualquer")
      end

      it "should return a Hash" do
        @response.should be_kind_of Hash
        @response.should == {
          :amount => "2",
          :number => nil,
          :message => "Approved",
          :return_code => "0",
          :status => "0",
          :transaction_id => nil
        }
      end
    end
  end

  describe ".save" do
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

    let(:savon) { double('Savon') }

    before do
      @connection.should_receive(:merchant_id)
    end

    context "with valid params" do
      let(:valid_xml) do
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <CartaoProtegidoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                       xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                       xmlns="https://cartaoprotegido.braspag.com.br/Services/CartaoProtegido.asmx">
          <JustClickKey>SAVE-PROTECTED-CARD-TOKEN</JustClickKey>
        </CartaoProtegidoReturn>
        EOXML
      end

      let(:response) do
        double('Response', :body => valid_xml)
      end
      before do
        Braspag::CreditCard.should_receive(:save_protected_card_url)
                           .and_return(save_protected_card_url)
        Braspag::CreditCard.should_receive(:check_protected_card_params)
                           .and_return(true)
        Savon::Client.should_receive(:new).and_return(savon)
        savon.should_receive(:request).and_return(response)

        @response = Braspag::CreditCard.save(params)
      end

      it "should return a Hash" do
        @response.should be_kind_of Hash
        @response.should == { :just_click_key => "SAVE-PROTECTED-CARD-TOKEN" }
      end
    end
  end

  describe ".get" do
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
      Braspag::CreditCard.should_receive(:valid_just_click_key?)
                         .with("bla")
                         .and_return(false)

      expect {
        Braspag::CreditCard.get "bla"
      }.to raise_error(Braspag::InvalidJustClickKey)
    end

    it "should raise an error when Braspag returned an invalid xml as response" do
      FakeWeb.register_uri(:post, get_protected_card_url, :body => invalid_xml)

      Braspag::CreditCard.should_receive(:get_protected_card_url)
                         .and_return(get_protected_card_url)

      expect {
        Braspag::CreditCard.get("b0b0b0b0-bbbb-4d4d-bd27-f1f1f1ededed")
      }.to raise_error(Braspag::UnknownError)
    end

    it "should return a Hash when Braspag returned a valid xml as response" do
      FakeWeb.register_uri(:post, get_protected_card_url, :body => valid_xml)

      Braspag::CreditCard.should_receive(:get_protected_card_url)
                         .and_return(get_protected_card_url)

      response = Braspag::CreditCard.get("b0b0b0b0-bbbb-4d4d-bd27-f1f1f1ededed")
      response.should be_kind_of Hash

      response.should == {
        :holder => "Joao Maria Souza",
        :expiration => "10/12",
        :card_number => "9" * 10,
        :masked_card_number => "*" * 6 + "9" * 4
      }
    end

  end

  describe ".just_click_shop" do
    let(:params) do
      {
        :customer_name =>  "Joao Maria Souza",
        :request_id => "um request id",
        :order_id => "um order id",
        :amount => "9.10",
        :payment_method => "20",
        :number_installments => "1",
        :payment_type => 0,
        :just_click_key => "b0b0b0b0-bbbb-4d4d-bd27-f1f1f1ededed",
        :security_code => "123"
      }
    end

    let(:params_with_merchant_id) do
      params.merge!(:merchant_id => merchant_id)
    end

    let(:just_click_shop_url) { "http://braspag/bla" }

    let(:invalid_xml) do
      <<-EOXML
      <CartaoProtegidoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <BraspagTransactionId>001</BraspagTransactionId>
        <AcquirerTransactionId>0001</AcquirerTransactionId>
        <Amount>10,00</Amount>
        <AuthorizationCode>01</AuthorizationCode>
        <Status></Status>
        <ReturnCode></ReturnCode>
        <ReturnMessage>Just testing</ReturnMessage>
        <Country>Brazil</Country>
        <Currency>BRL</Currency>
      </CartaoProtegidoReturn>
      EOXML
    end

    let(:valid_xml) do
      <<-EOXML
      <CartaoProtegidoReturn xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <BraspagTransactionId>001</BraspagTransactionId>
        <AcquirerTransactionId>0001</AcquirerTransactionId>
        <Amount>10.00</Amount>
        <AuthorizationCode>01</AuthorizationCode>
        <Status>1</Status>
        <ReturnCode>1</ReturnCode>
        <ReturnMessage>It works</ReturnMessage>
        <Country>Brazil</Country>
        <Currency>BRL</Currency>
      </CartaoProtegidoReturn>
      EOXML
    end

    it "should return a Hash when Braspag returned a valid xml as response" do
      FakeWeb.register_uri(:post, just_click_shop_url, :body => valid_xml)

      Braspag::CreditCard.should_receive(:just_click_shop_url)
                         .and_return(just_click_shop_url)

      response = Braspag::CreditCard.just_click_shop(params_with_merchant_id)
      response.should be_kind_of Hash

      response.should == {
        :transaction_id => "001",
        :acquirer_transaction_id => "0001",
        :amount => "10.00",
        :authorization_code => "01",
        :status => "1",
        :return_code => "1",
        :return_message => "It works",
        :country => "Brazil",
        :currency => "BRL"
      }
    end

  end



  describe ".info" do
    let(:info_url) { "http://braspag/bla" }

    let(:invalid_xml) do
      <<-EOXML
      <DadosCartao xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <NumeroComprovante></NumeroComprovante>
        <Autenticada>false</Autenticada>
        <NumeroAutorizacao>557593</NumeroAutorizacao>
        <NumeroCartao>345678*****0007</NumeroCartao>
        <NumeroTransacao>101001225645</NumeroTransacao>
      </DadosCartao>
      EOXML
    end

    let(:valid_xml) do
      <<-EOXML
      <DadosCartao xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <NumeroComprovante>11111</NumeroComprovante>
        <Autenticada>false</Autenticada>
        <NumeroAutorizacao>557593</NumeroAutorizacao>
        <NumeroCartao>345678*****0007</NumeroCartao>
        <NumeroTransacao>101001225645</NumeroTransacao>
      </DadosCartao>
      EOXML
    end

    it "should raise an error when order id is not valid" do
      Braspag::CreditCard.should_receive(:valid_order_id?)
                         .with("bla")
                         .and_return(false)

      expect {
        Braspag::CreditCard.info "bla"
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when Braspag returned an invalid xml as response" do
      FakeWeb.register_uri(:post, info_url, :body => invalid_xml)

      Braspag::CreditCard.should_receive(:info_url)
                         .and_return(info_url)

      expect {
        Braspag::CreditCard.info("orderid")
      }.to raise_error(Braspag::UnknownError)
    end

    it "should return a Hash when Braspag returned a valid xml as response" do
      FakeWeb.register_uri(:post, info_url, :body => valid_xml)

      Braspag::CreditCard.should_receive(:info_url)
                         .and_return(info_url)

      response = Braspag::CreditCard.info("orderid")
      response.should be_kind_of Hash

      response.should == {
        :checking_number => "11111",
        :certified => "false",
        :autorization_number => "557593",
        :card_number => "345678*****0007",
        :transaction_number => "101001225645"
      }
    end
  end

  describe ".check_params" do
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

  describe ".info_url" do
    it "should return the correct info url when connection environment is homologation" do
      @connection.stub(:braspag_url => braspag_homologation_url)
      @connection.should_receive(:production?)
                 .and_return(false)

      Braspag::CreditCard.info_url.should == "#{braspag_homologation_url}/pagador/webservice/pedido.asmx/GetDadosCartao"
    end

    it "should return the correct info url when connection environment is production" do
      @connection.stub(:braspag_url => braspag_production_url)
      @connection.should_receive(:production?)
                 .and_return(true)

      Braspag::CreditCard.info_url.should == "#{braspag_production_url}/webservices/pagador/pedido.asmx/GetDadosCartao"
    end
  end

  describe ".authorize_url .capture_url .cancellation_url" do
    it "should return the correct credit card creation url when connection environment is homologation" do
      @connection.stub(:braspag_url => braspag_homologation_url)

      Braspag::CreditCard.authorize_url.should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/Authorize"
      Braspag::CreditCard.capture_url.should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/Capture"
      Braspag::CreditCard.cancellation_url.should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/VoidTransaction"
    end

    it ".save_protected_card_url .get_protected_card_url" do
      @connection.stub(:protected_card_url => braspag_homologation_protected_card_url)

      Braspag::CreditCard.save_protected_card_url.should == "#{braspag_homologation_protected_card_url}/CartaoProtegido.asmx/SaveCreditCard"
      Braspag::CreditCard.get_protected_card_url.should == "#{braspag_homologation_protected_card_url}/CartaoProtegido.asmx/GetCreditCard"
    end


    it "should return the correct credit card creation url when connection environment is production" do
      @connection.stub(:braspag_url => braspag_production_url)

      Braspag::CreditCard.authorize_url.should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/Authorize"
      Braspag::CreditCard.capture_url.should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/Capture"
      Braspag::CreditCard.cancellation_url.should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/VoidTransaction"
    end

    it "should return the correct protected credit card url when connection environment is production" do
      @connection.stub(:protected_card_url => braspag_production_protected_card_url)

      Braspag::CreditCard.save_protected_card_url.should == "#{braspag_production_protected_card_url}/CartaoProtegido.asmx/SaveCreditCard"
      Braspag::CreditCard.get_protected_card_url.should == "#{braspag_production_protected_card_url}/CartaoProtegido.asmx/GetCreditCard"
    end
  end
end
