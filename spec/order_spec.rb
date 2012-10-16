# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Order do
  let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
  let(:braspag_production_url) { "https://transaction.pagador.com.br" }
  let(:merchant_id) { "um id qualquer" }

  before do
    @connection = mock(:merchant_id => merchant_id)
    Braspag::Connection.stub(:instance => @connection)
  end
  
  pending ".info_url" do
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

  describe ".status" do
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

  describe ".status_url" do
    it "should return the correct info url when connection environment is homologation" do
      @connection.stub(:braspag_url => braspag_homologation_url)
      @connection.should_receive(:production?)
                 .and_return(false)

      Braspag::Order.status_url.should == "#{braspag_homologation_url}/pagador/webservice/pedido.asmx/GetDadosPedido"
    end

    it "should return the correct info url when connection environment is production" do
      @connection.stub(:braspag_url => braspag_production_url)
      @connection.should_receive(:production?)
                 .and_return(true)

      Braspag::Order.status_url.should == "#{braspag_production_url}/webservices/pagador/pedido.asmx/GetDadosPedido"
    end
  end
end
