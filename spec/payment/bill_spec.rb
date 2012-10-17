# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Bill do
  let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
  let(:braspag_production_url) { "https://transaction.pagador.com.br" }
  let(:merchant_id) { "um id qualquer" }

  before do
    @connection = mock(:merchant_id => merchant_id)
    Braspag::Connection.stub(:instance => @connection)
  end

  describe ".generate" do
    let(:params) do
      {
        :order_id => 11,
        :amount => 3,
        :payment_method => :hsbc
      }
    end

    let(:params_with_merchant_id) do
      params.merge!(:merchant_id => merchant_id)
    end

    let(:creation_url) { "https://bla.com/foo/bar/baz" }

    before do
      @connection.should_receive(:merchant_id)

      Braspag::Bill.should_receive(:creation_url)
                   .and_return(creation_url)

      Braspag::Bill.should_receive(:normalize_params)
                   .with(params_with_merchant_id)
                   .and_return(params_with_merchant_id)

      Braspag::Bill.should_receive(:check_params)
                   .and_return(true)
    end

    context "with invalid params" do
      it "should raise an error when Braspag returns 'Invalid merchantId' as response" do
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

        FakeWeb.register_uri(:post, creation_url, :body => xml)

        expect {
          Braspag::Bill.generate(params)
        }.to raise_error(Braspag::InvalidMerchantId)
      end

      it "should raise an error when Braspag returns 'Input string was not in a correct format' as response" do
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

        FakeWeb.register_uri(:post, creation_url, :body => xml)

        expect {
          Braspag::Bill.generate(params)
        }.to raise_error(Braspag::InvalidStringFormat)
      end

      it "should raise an error when Braspag returns 'Invalid payment method' as response" do
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

        FakeWeb.register_uri(:post, creation_url, :body => xml)

        expect {
          Braspag::Bill.generate(params)
        }.to raise_error(Braspag::InvalidPaymentMethod)
      end

      it "should raise an error when Braspag returns 'Invalid purchase amount' as response" do
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

        FakeWeb.register_uri(:post, creation_url, :body => xml)

        expect {
          Braspag::Bill.generate(params)
        }.to raise_error(Braspag::InvalidAmount)
      end

      it "should raise an error when Braspag returns any other error as response" do
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

        FakeWeb.register_uri(:post, creation_url, :body => xml)

        expect {
          Braspag::Bill.generate(params)
        }.to raise_error(Braspag::UnknownError)
      end
    end

    context "with valid params" do
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

      let(:params) do
        {
          :order_id => 2901,
          :amount => 3,
          :payment_method => :real,
          :number => "123123",
          :expiration_date => Date.today.strftime("%d/%m/%y")
        }
      end

      before do
        FakeWeb.register_uri(:post, creation_url, :body => valid_xml)
        @response = Braspag::Bill.generate(params)
      end

      it "should return a Hash" do
        @response.should be_kind_of Hash
        @response.should == {
          :url => "https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=722934be-6756-477a-87ab-42115ee1424d",
          :amount => BigDecimal.new("3.00"),
          :number => "123123",
          :expiration_date => Date.new(2012, 1, 8),
          :return_code => "0",
          :status => "0",
          :message => nil
        }
      end
    end
  end

  describe ".normalize_params" do
    it "should format the expiration_date param" do
      params = { :expiration_date => Date.new(2011, 12, 10) }

      result = Braspag::Bill.normalize_params(params)
      result.should be_kind_of Hash

      result[:expiration_date].should =~ /10\/12\/11/
    end

    it "should convert amount to BigDecimal" do
      params = { :amount => "100.2" }

      result = Braspag::Bill.normalize_params(params)
      result.should be_kind_of Hash

      result[:amount].should be_kind_of BigDecimal
    end
  end

  describe ".check_params" do
    let(:params) do
      {
        :order_id => "111",
        :amount => 100.0,
        :payment_method => :bradesco
      }
    end

    [:order_id, :amount, :payment_method].each do |param|
      it "should raise an error when #{param} is not present" do
        expect {
          params[param] = nil
          Braspag::Bill.check_params(params)
        }.to raise_error Braspag::IncompleteParams
      end
    end

    it "should raise an error when order_id is not valid" do
      Braspag::Bill.should_receive(:valid_order_id?)
                   .with(params[:order_id])
                   .and_return(false)

      expect {
        Braspag::Bill.check_params(params)
      }.to raise_error Braspag::InvalidOrderId
    end

    it "should raise an error when customer_name is present and is greater than 255 chars" do
      expect {
        params[:customer_name] = "b" * 256
        Braspag::Bill.check_params(params)
      }.to raise_error Braspag::InvalidCustomerName
    end

    it "should raise an error when customer_id is present and is greater than 18 chars" do
      expect {
        params[:customer_id] = "1" * 19
        Braspag::Bill.check_params(params)
      }.to raise_error Braspag::InvalidCustomerId
    end

    it "should raise an error when customer_id is present and is less than 11 chars" do
      expect {
        params[:customer_id] = "1" * 10
        Braspag::Bill.check_params(params)
      }.to raise_error Braspag::InvalidCustomerId
    end

    it "should raise an error when number is present and is greater than 255 chars" do
      expect {
        params[:number] = "1" * 256
        Braspag::Bill.check_params(params)
      }.to raise_error Braspag::InvalidNumber
    end

    it "should raise an error when instructions is present and is greater than 512 chars" do
      expect {
        params[:instructions] = "A" * 513
        Braspag::Bill.check_params(params)
      }.to raise_error Braspag::InvalidInstructions
    end

    it "should raise an error when expiration_date is present and is not in a valid format" do
      expect {
        params[:expiration_date] = "2011/19/19"
        Braspag::Bill.check_params(params)
      }.to raise_error Braspag::InvalidExpirationDate

      expect {
        params[:expiration_date] = "29/10/1991"
        Braspag::Bill.check_params(params)
      }.to_not raise_error Braspag::InvalidExpirationDate
    end

    it "should raise an error when payment_method is not invalid" do
      expect {
        params[:payment_method] = "non ecziste"
        Braspag::Bill.check_params(params)
      }.to raise_error Braspag::InvalidPaymentMethod
    end
  end

  describe ".valid_order_id?" do
    it "should return false when order id is greater than 50 chars" do
      Braspag::Bill.valid_order_id?("A"*51).should be_false
    end

    it "should return false when order id is not a String or Fixnum" do
      Braspag::Bill.valid_order_id?(nil).should be_false
    end

    it "should return true" do
      Braspag::Bill.valid_order_id?("A"*50).should be_true
      Braspag::Bill.valid_order_id?(100).should be_true
    end
  end

  describe ".info" do
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


end
