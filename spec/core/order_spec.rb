# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Order do
  let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
  let(:braspag_production_url) { "https://transaction.pagador.com.br" }
  let(:merchant_id) { "um id qualquer" }

  
  pending ".info_billet" do
    let(:info_url) { "http://braspag/bla" }
    let(:invalid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <DadosBoleto xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xsi:nil="true"
                   xmlns="http://www.pagador.com.br/" />
      EOXML
    end

    let(:valid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <DadosBoleto xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
      <NumeroDocumento>999</NumeroDocumento>
      <Sacado/>
      <NossoNumero>999</NossoNumero>
      <LinhaDigitavel>35690.00361 03962.070003 00000.009993 4 50160000001000</LinhaDigitavel>
      <DataDocumento>22/6/2011</DataDocumento>
      <DataVencimento>2/7/2011</DataVencimento>
      <Cedente>Gonow Tecnologia e Acessoria Empresarial Ltda</Cedente>
      <Banco>356-5</Banco>
      <Agencia>0003</Agencia>
      <Conta>6039620</Conta>
      <Carteira>57</Carteira>
      <ValorDocumento>10,00</ValorDocumento>
      </DadosBoleto>
      EOXML
    end

    it "should raise an error when order id is not valid" do
      Braspag::Bill.should_receive(:valid_order_id?)
                   .with("bla")
                   .and_return(false)

      expect {
        Braspag::Bill.info "bla"
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when Braspag returned an invalid xml as response" do
      FakeWeb.register_uri(:post, info_url, :body => invalid_xml)

      Braspag::Bill.should_receive(:info_url)
                   .and_return(info_url)

      expect {
        Braspag::Bill.info("orderid")
      }.to raise_error(Braspag::UnknownError)
    end

    it "should return a Hash when Braspag returned a valid xml as response" do
      FakeWeb.register_uri(:post, info_url, :body => valid_xml)

      Braspag::Bill.should_receive(:info_url)
                   .and_return(info_url)

      response = Braspag::Bill.info("orderid")
      response.should be_kind_of Hash

      response.should == {
        :document_number => "999",
        :payer => nil,
        :our_number => "999",
        :bill_line => "35690.00361 03962.070003 00000.009993 4 50160000001000",
        :document_date => "22/6/2011",
        :expiration_date => "2/7/2011",
        :receiver => "Gonow Tecnologia e Acessoria Empresarial Ltda",
        :bank => "356-5",
        :agency => "0003",
        :account => "6039620",
        :wallet => "57",
        :amount => "10,00",
        :amount_invoice => nil,
        :invoice_date => nil
      }
    end
  end
  
  pending ".info" do
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

  pending ".status" do
    let(:order_id) { "um order id qualquer" }
    let(:status_url) { "http://foo.com/bar/baz/assererre" }

    context "with invalid order id" do
      let(:invalid_xml) do
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <DadosBoleto xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                     xsi:nil="true"
                     xmlns="http://www.pagador.com.br/" />
        EOXML
      end

      it "should raise an error when order id is not valid" do
        Braspag::PaymentMethod.should_receive(:valid_order_id?)
                              .with(order_id)
                              .and_return(false)

        expect {
          Braspag::Order.status(order_id)
        }.to raise_error(Braspag::InvalidOrderId)
      end

      it "should raise an error when Braspag returns an invalid xml" do
        FakeWeb.register_uri(:post, status_url, :body => invalid_xml)

        Braspag::Order.should_receive(:status_url)
                      .and_return(status_url)

        expect {
          Braspag::Order.status(order_id)
        }.to raise_error(Braspag::Order::InvalidData)
      end
    end

    context "with valid order id" do
      let(:valid_xml) do
        <<-EOXML
        <?xml version="1.0" encoding="utf-8"?>
        <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                     xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                     xmlns="http://www.pagador.com.br/">
          <CodigoAutorizacao>885796</CodigoAutorizacao>
          <CodigoPagamento>18</CodigoPagamento>
          <FormaPagamento>American Express 2P</FormaPagamento>
          <NumeroParcelas>1</NumeroParcelas>
          <Status>3</Status>
          <Valor>0.01</Valor>
          <DataPagamento>7/8/2011 1:19:38 PM</DataPagamento>
          <DataPedido>7/8/2011 1:06:06 PM</DataPedido>
          <TransId>398591</TransId>
          <BraspagTid>5a1d4463-1d11-4571-a877-763aba0ef7ff</BraspagTid>
        </DadosPedido>
        EOXML
      end

      before do
        Braspag::Order.should_receive(:status_url)
                      .and_return(status_url)

        FakeWeb.register_uri(:post, status_url, :body => valid_xml)
        @response = Braspag::Order.status(order_id)
      end

      it "should return a Hash" do
        @response.should be_kind_of Hash
        @response.should == {
          :authorization => "885796",
          :error_code => nil,
          :error_message => nil,
          :payment_method => "18",
          :payment_method_name => "American Express 2P",
          :installments => "1",
          :status => "3",
          :amount => "0.01",
          :cancelled_at => nil,
          :paid_at => "7/8/2011 1:19:38 PM",
          :order_date => "7/8/2011 1:06:06 PM",
          :transaction_id => "398591",
          :tid => "5a1d4463-1d11-4571-a877-763aba0ef7ff"
        }
      end
    end
  end

  
  [:purchase, :generate, :authorize, :capture, :void, :recurrency].each do |context_type|
    context "on #{context_type}" do
      it "should validate minimum 1 length of id" do
        subject.id = ''
        subject.valid?(context_type)
        subject.errors.messages[:id].should include("is too short (minimum is 1 characters)")
      end

      it "should validate maximum 20 length of id" do
        subject.id = '*' * 25
        subject.valid?(context_type)
        subject.errors.messages[:id].should include("is too long (maximum is 20 characters)")
      end

      it "should allow characters without payment_method"  do
        subject.id = '*13*'
        subject.valid?(context_type)
        subject.errors.messages[:id].should eq(nil)
      end
      
      [:cielo_noauth_visa, :cielo_preauth_visa, :cielo_noauth_mastercard, :cielo_preauth_mastercard, :cielo_noauth_elo, :cielo_noauth_diners ].each do |payment_method|
        context "when has payment method for #{payment_method}" do
          it "should not allow spaces" do
            subject.payment_method = Braspag::PAYMENT_METHOD[payment_method]
            subject.id = '123 4'
            subject.valid?(context_type)
            subject.errors.messages[:id].should include("is invalid")
          end
          it "should not allow characters" do
            subject.payment_method = Braspag::PAYMENT_METHOD[payment_method]
            subject.id = 'abcd'
            subject.valid?(context_type)
            subject.errors.messages[:id].should include("is invalid")
          end

          it "should not allow special characters" do
            subject.payment_method = Braspag::PAYMENT_METHOD[payment_method]
            subject.id = '*-[]'
            subject.valid?(context_type)
            subject.errors.messages[:id].should include("is invalid")
          end
        end
      end
    end
  end
  
  [:purchase, :generate, :authorize, :recurrency].each do |context_type|
    context "on #{context_type}" do
      it "should not allow blank for payment_method" do
        subject.payment_method = ''
        subject.valid?(context_type)
        subject.errors.messages[:payment_method].should include("can't be blank")
      end
    
      it "should not allow blank for amount" do
        subject.amount = ''
        subject.valid?(context_type)
        subject.errors.messages[:amount].should include("can't be blank")
      end
    
      it "should validate minimum 1 of amount" do
        subject.amount = 0
        subject.valid?(context_type)
        subject.errors.messages[:amount].should include("must be greater than 0")
      end
    
      it "should not allow blank for customer" do
        subject.customer = ''
        subject.valid?(context_type)
        subject.errors.messages[:customer].should include("can't be blank")
      end

      it "should not allow invalid customer" do
        subject.customer = Braspag::Customer.new
        subject.valid?(context_type)
        subject.errors.messages[:customer].should include("invalid data")
      end
    
      it "should accept only valid payment method" do
        subject.payment_method = 0
        subject.valid?(context_type)
        subject.errors.messages[:payment_method].should include("invalid payment code")
      end
    end
  end

  [:purchase, :authorize, :recurrency].each do |context_type|
    context "on #{context_type}" do
      it "should not allow blank for installments" do
        subject.installments = ''
        subject.valid?(context_type)
        subject.errors.messages[:installments].should include("can't be blank")
      end
    
      it "should validate minimum 1 of installments" do
        subject.installments = 0
        subject.valid?(context_type)
        subject.errors.messages[:installments].should include("must be greater than 0")
      end
    
    
      it "should validate maxium 99 of installments" do
        subject.installments = 100
        subject.valid?(context_type)
        subject.errors.messages[:installments].should include("must be less than 100")
      end
    
      it "should not allow blank for installments_type" do
        subject.installments_type = ''
        subject.valid?(context_type)
        subject.errors.messages[:installments_type].should include("can't be blank")
      end
    
      it "should accept only valid installments_type" do
        subject.installments_type = 100
        subject.valid?(context_type)
        subject.errors.messages[:installments_type].should include("invalid installments type")
      end
    
    
      context "when installments_type is NO_INTEREST" do
        it "should installments is one" do
          subject.installments_type = Braspag::INTEREST[:no]
          subject.installments = 3
          subject.valid?(context_type)
          subject.errors.messages[:installments].should include("is invalid")
        end
      end
    end
  end
end
