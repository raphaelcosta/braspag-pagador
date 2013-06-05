# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BraspagPagador::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
  let(:order) { BraspagPagador::Order.new(:id => "XPTO") }

  describe ".get" do
    context "when error" do
      it "should return message for response blank" do
        connection.stub(:post).and_return({})
        response = connection.get(order)

        response.success?.should eq(false)
        response.message.should eq('')
        response.params.should eq({})
        response.test.should eq(true)
      end

      it "should return message for error code" do
        order_response = {:error_code => 'bla', :error_message => 'xpto', :status => '223'}
        connection.stub(:post).and_return(order_response)
        response = connection.get(order)

        response.success?.should eq(false)
        response.message.should eq(order_response[:error_message])
        response.params.should eq({"error_code"=>"bla", "error_message"=>"xpto", "status" => '223'})
        response.test.should eq(true)
      end

      it "should return message for empty status" do
        connection.stub(:post).and_return({:error_message => 'bla'})
        response = connection.get(order)

        response.success?.should eq(false)
        response.message.should eq('bla')
        response.params.should eq({"error_message"=>"bla"})
        response.test.should eq(true)
      end
    end

    it "should return response ok" do
      connection.stub(:post).and_return({:status => '1'})
      response = connection.get(order)

      response.success?.should eq(true)
      response.message.should eq('OK')
      response.params.should eq({"status" => "1"})
      response.test.should eq(true)
    end

    it "should get more info for billet" do
      connection.should_receive(:post).and_return({:status => '1'})
      connection.should_receive(:post).with(:info_billet, order)
      order.payment_method = 6 #BILLET BRADESCO
      response = connection.get(order)

      response.success?.should eq(true)
      response.message.should eq('OK')
      response.params.should eq({"status" => "1"})
      response.test.should eq(true)
    end

    it "should get more info for credit_card" do
      connection.should_receive(:post).and_return({:status => '1'})
      connection.should_receive(:post).with(:info_credit_card, order)
      order.payment_method = 18 #AMEX
      response = connection.get(order)

      response.success?.should eq(true)
      response.message.should eq('OK')
      response.params.should eq({"status" => "1"})
      response.test.should eq(true)
    end
  end
end

describe BraspagPagador::Order do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}

  describe ".payment_method_type?" do
    it "should return payment method type" do
      order = subject
      order.payment_method = 6
      order.payment_method_type?.should eq(:billet)
    end
  end

  context "on info" do
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
        <DataCancelamento>7/8/2011 1:19:38 PM</DataCancelamento>
        <DataPagamento>7/8/2011 1:19:38 PM</DataPagamento>
        <DataPedido>7/8/2011 1:06:06 PM</DataPedido>
        <TransId>398591</TransId>
        <BraspagTid>5a1d4463-1d11-4571-a877-763aba0ef7ff</BraspagTid>
      </DadosPedido>
      EOXML
    end

    let(:invalid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xsi:nil="true"
                   xmlns="http://www.pagador.com.br/" />
      EOXML
    end

    let(:error_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <CodigoErro>885796</CodigoErro>
        <MensagemErro>Deu um erro terrivel</MensagemErro>
      </DadosPedido>
      EOXML
    end

    let(:order) { BraspagPagador::Order.new(:id => "XPTO") }

    it "should convert objects to hash" do
      BraspagPagador::Order.to_info(connection, order).should eq({
        "loja"          => "#{merchant_id}",
        "numeroPedido"  => "#{order.id}"
      })
    end

    it "should populate data" do
      resp = BraspagPagador::Order.from_info(connection, order, mock(:body => valid_xml))

      order.authorization.should eq('885796')
      order.payment_method_name.should eq('American Express 2P')
      order.payment_method.should eq('18')
      order.installments.should eq('1')
      order.status.should eq('3')
      order.amount.should eq(0.01)
      order.gateway_cancelled_at.should eq(Time.parse('2011-08-07 13:19:38'))
      order.gateway_paid_at.should eq(Time.parse('2011-08-07 13:19:38'))
      order.gateway_created_at.should eq(Time.parse('2011-08-07 13:06:06'))
      order.transaction_id.should eq('398591')
      order.gateway_id.should eq('5a1d4463-1d11-4571-a877-763aba0ef7ff')

      resp.should eq({
        :authorization       => "885796",
        :error_code          => nil,
        :error_message       => nil,
        :payment_method      => "18",
        :payment_method_name => "American Express 2P",
        :installments        => "1",
        :status              => "3",
        :amount              => "0.01",
        :cancelled_at        => Time.parse('2011-08-07 13:19:38'),
        :paid_at             => Time.parse('2011-08-07 13:19:38'),
        :order_date          => Time.parse('2011-08-07 13:06:06'),
        :transaction_id      => "398591",
        :tid                 => "5a1d4463-1d11-4571-a877-763aba0ef7ff"
      })
    end

    it "should populate data accepts invalid xml" do
      resp = BraspagPagador::Order.from_info(connection, order, mock(:body => invalid_xml))

      resp.should eq({
        :authorization       => nil,
        :error_code          => nil,
        :error_message       => nil,
        :payment_method      => nil,
        :payment_method_name => nil,
        :installments        => nil,
        :status              => nil,
        :amount              => nil,
        :cancelled_at        => nil,
        :paid_at             => nil,
        :order_date          => nil,
        :transaction_id      => nil,
        :tid                 => nil
      })
    end

    it "should populate data for error" do
      resp = BraspagPagador::Order.from_info(connection, order, mock(:body => error_xml))

      resp.should eq({
        :authorization       => nil,
        :error_code          => "885796",
        :error_message       => "Deu um erro terrivel",
        :payment_method      => nil,
        :payment_method_name => nil,
        :installments        => nil,
        :status              => nil,
        :amount              => nil,
        :cancelled_at        => nil,
        :paid_at             => nil,
        :order_date          => nil,
        :transaction_id      => nil,
        :tid                 => nil
      })
    end
  end

  context "on info for billet" do
    let(:valid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <DadosBoleto xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
      <NumeroDocumento>999</NumeroDocumento>
      <Sacado>XPTO</Sacado>
      <NossoNumero>999</NossoNumero>
      <LinhaDigitavel>35690.00361 03962.070003 00000.009993 4 50160000001000</LinhaDigitavel>
      <DataDocumento>22/6/2011</DataDocumento>
      <DataVencimento>2/7/2011</DataVencimento>
      <DataCredito>2/7/2011</DataCredito>
      <Cedente>Acessoria Empresarial Ltda</Cedente>
      <Banco>356-5</Banco>
      <Agencia>0003</Agencia>
      <Conta>6039620</Conta>
      <Carteira>57</Carteira>
      <ValorDocumento>10,00</ValorDocumento>
      <ValorPago>10,00</ValorPago>
      </DadosBoleto>
      EOXML
    end

    let(:invalid_xml) do
      <<-EOXML
      <?xml version="1.0" encoding="utf-8"?>
      <DadosBoleto xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
      </DadosBoleto>
      EOXML
    end

    let(:order) { BraspagPagador::Order.new(:id => "XPTO") }

    it "should convert objects to hash" do
      BraspagPagador::Order.to_info_billet(connection, order).should eq({
        "loja"          => "#{merchant_id}",
        "numeroPedido"  => "#{order.id}"
      })
    end

    it "should populate data" do
      resp = BraspagPagador::Order.from_info_billet(connection, order, mock(:body => valid_xml))

      order.customer.name.should eq('XPTO')

      order.billet.id.should eq('999')
      order.billet.code.should eq('35690.00361 03962.070003 00000.009993 4 50160000001000')

      order.billet.created_at.should eq(Date.parse('2011-06-22'))
      order.billet.due_date_on.should eq(Date.parse('2011-07-2'))

      order.billet.receiver.should eq('Acessoria Empresarial Ltda')

      order.billet.bank.should eq('356-5')
      order.billet.agency.should eq('0003')
      order.billet.account.should eq('6039620')
      order.billet.wallet.should eq('57')
      order.billet.amount.should eq(10.00)
      order.billet.amount_paid.should eq(10.00)
      order.billet.paid_at.should eq(Date.parse('2011-07-02'))

      resp.should eq({
        :document_number=>"999",
        :payer=>"XPTO",
        :our_number=>"999",
        :bill_line=>"35690.00361 03962.070003 00000.009993 4 50160000001000",
        :document_date=>Date.parse('2011-06-22'),
        :expiration_date=>Date.parse('2011-07-2'),
        :receiver=>"Acessoria Empresarial Ltda",
        :bank=>"356-5",
        :agency=>"0003",
        :account=>"6039620",
        :wallet=>"57",
        :amount=>"10,00",
        :amount_invoice=>"10,00",
        :invoice_date=> Date.parse('2011-07-02')
      })
    end

    it "should not raise error for invalid xml" do
      resp = BraspagPagador::Order.from_info_billet(connection, order, mock(:body => invalid_xml))

      resp.should eq({
        :document_number => nil,
        :payer => nil,
        :our_number => nil,
        :bill_line => nil,
        :document_date => nil,
        :expiration_date => nil,
        :receiver => nil,
        :bank=> nil,
        :agency=> nil,
        :account=> nil,
        :wallet=> nil,
        :amount=> nil,
        :amount_invoice=> nil,
        :invoice_date=> nil
      })
    end
  end

  context "on info for credit card" do
    let(:valid_xml) do
      <<-EOXML
      <DadosCartao xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                   xmlns:xsd="http://www.w3.org/2001/XMLSchema"
                   xmlns="http://www.pagador.com.br/">
        <RetornoAVS>12</RetornoAVS>
        <Emissor>VISA</Emissor>
        <NumeroAutenticacao>12345</NumeroAutenticacao>
        <NumeroComprovante>11111</NumeroComprovante>
        <Autenticada>false</Autenticada>
        <NumeroAutorizacao>557593</NumeroAutorizacao>
        <NumeroCartao>345678*****0007</NumeroCartao>
        <NumeroTransacao>101001225645</NumeroTransacao>
      </DadosCartao>
      EOXML
    end

    let(:order) { BraspagPagador::Order.new(:id => "XPTO") }

    it "should convert objects to hash" do
      BraspagPagador::Order.to_info_credit_card(connection, order).should eq({
        "loja"          => "#{merchant_id}",
        "numeroPedido"  => "#{order.id}"
      })
    end

    it "should populate data" do
      resp = BraspagPagador::Order.from_info_credit_card(connection, order, mock(:body => valid_xml))

      order.credit_card.checking_number.should eq('11111')
      order.credit_card.avs.should eq('false')
      order.credit_card.autorization_number.should eq('557593')
      order.credit_card.number.should eq('345678*****0007')
      order.credit_card.transaction_number.should eq('101001225645')
      order.credit_card.avs_response.should eq('12')
      order.credit_card.issuing.should eq('VISA')
      order.credit_card.authenticated_number.should eq('12345')

      resp.should eq({
        :checking_number      => "11111",
        :certified            => "false",
        :autorization_number  => "557593",
        :card_number          => "345678*****0007",
        :transaction_number   => "101001225645",
        :avs_response         => "12",
        :issuing              => "VISA",
        :authenticated_number => "12345"
      })
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
            subject.payment_method = BraspagPagador::PAYMENT_METHOD[payment_method]
            subject.id = '123 4'
            subject.valid?(context_type)
            subject.errors.messages[:id].should include("is invalid")
          end
          it "should not allow characters" do
            subject.payment_method = BraspagPagador::PAYMENT_METHOD[payment_method]
            subject.id = 'abcd'
            subject.valid?(context_type)
            subject.errors.messages[:id].should include("is invalid")
          end

          it "should not allow special characters" do
            subject.payment_method = BraspagPagador::PAYMENT_METHOD[payment_method]
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
        subject.customer = BraspagPagador::Customer.new
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
          subject.installments_type = BraspagPagador::INTEREST[:no]
          subject.installments = 3
          subject.valid?(context_type)
          subject.errors.messages[:installments].should include("is invalid")
        end
      end
    end
  end
end
