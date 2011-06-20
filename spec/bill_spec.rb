#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Bill do
  before do
    @merchant_id = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
    @connection = Braspag::Connection.new(@merchant_id, :test)
  end

  context "consistência" do

    #TODO Checkar Tamanhos segundo tabela do braspag
    #TODO Melhorar conexao
    #TODO Refatorar nomes dos testes para ingles
    #TODO Sugar Syntax p/ aceitar objetos data no expirtaionDate
    #TODO Parser objeto de retorno no expirtionDate deve retornar um objeto DateTime
    #TODO Transformar numeros magicos em symbols, por exemplo metodo de pagamento pode ser :real ao inves de 10
    

    it "para connection" do
      expect {
        Braspag::Bill.new("11")
      }.to raise_error(Braspag::InvalidConnection)
    end


    it "para orderId" do
      expect {
        Braspag::Bill.new(@connection)
      }.to raise_error(Braspag::Bill::InvalidOrderId)
    end

    it "para amount" do
      expect {
        Braspag::Bill.new(@connection , {
            :orderId => 1
          })
      }.to raise_error(Braspag::Bill::InvalidAmount)
    end

    it "para paymentMethod" do
      expect {
        Braspag::Bill.new(@connection , {
            :orderId => 1,
            :amount => 3
          })
      }.to raise_error(Braspag::Bill::InvalidPaymentMethod)
    end
  end

  context "ao gerar um boleto com dados corretos" do
    before do
      FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<PagadorBoletoReturn xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"https://www.pagador.com.br/webservice/pagador\">\r\n  <amount>3</amount>\r\n  <boletoNumber>70031</boletoNumber>\r\n  <expirationDate>2011-06-27T00:00:00-03:00</expirationDate>\r\n  <url>https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=34ae7d96-aa65-425a-b893-55791cb6a4df</url>\r\n  <returnCode>0</returnCode>\r\n  <status>0</status>\r\n</PagadorBoletoReturn>")
      @bill =  Braspag::Bill.new(@connection , {
          :orderId => 1,
          :amount => 3,
          :paymentMethod => 10
        })
      @response = @bill.generate
    end

    after do
      FakeWeb.clean_registry
    end

    it "deverá retornar url p/ acesso ao boleto" do
      @response[:url].should == "https://homologacao.pagador.com.br/pagador/reenvia.asp?Id_Transacao=34ae7d96-aa65-425a-b893-55791cb6a4df"
    end

    it "deverá retornar status 0 (Aguardando Pagamento)" do
      @response[:status].should == "0"
    end

    it "deverá retornar returnCode 0 (Sucesso)" do
      @response[:returnCode].should == "0"
    end

    it "deverá retornar valor do boleto" do
      @response[:amount].should == "3"
    end

    it "deverá retornar número do boleto" do
      @response[:number].should == "70031"
    end

    it "deverá retornar número sequencial do boleto" do
      @response[:number].should == "70031"
    end

    it "deverá retornar data de expiração do boleto" do
      @response[:expirationDate].should == "2011-06-27T00:00:00-03:00"
    end
  end

  context "ao gerar um boleto com dados incorretos" do

    it "para merchant_id deverá gerar uma exeção" do
      FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => "<?xml version=\"1.0\" encoding=\"utf-8\"?>\r\n<PagadorBoletoReturn xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"https://www.pagador.com.br/webservice/pagador\">\r\n  <amount xsi:nil=\"true\" />\r\n  <expirationDate xsi:nil=\"true\" />\r\n  <returnCode>1</returnCode>\r\n  <message>Invalid merchantId</message>\r\n  <status xsi:nil=\"true\" />\r\n</PagadorBoletoReturn>")
      connection = Braspag::Connection.new("X-YX:7", :test)
      expect {
        bill =  Braspag::Bill.new(connection , {
            :orderId => 1,
            :amount => 3,
            :paymentMethod => 10
          })
        bill.generate
      }.to raise_error(Braspag::InvalidMerchantId)
      FakeWeb.clean_registry
    end


    it "para :boletoNumber deverá gerar uma exeção" do
      FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => "<?xml version=\"1.0\" encoding=\"utf-8\"?><PagadorBoletoReturn xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"https://www.pagador.com.br/webservice/pagador\"><amount xsi:nil=\"true\" /><expirationDate xsi:nil=\"true\" /><returnCode>1</returnCode><message>Input string was not in a correct format.</message><status xsi:nil=\"true\" /></PagadorBoletoReturn>")
      expect {
        x = "OI\n"
        1024.times { x = x.concat"1" }
        bill =  Braspag::Bill.new(@connection , {
            :boletoNumber => x,
            :orderId => "x",
            :amount => 3,
            :paymentMethod => 10
          })
        bill.generate
      }.to raise_error(Braspag::Bill::InvalidStringFormat)
      FakeWeb.clean_registry
    end

    it "para paymentMethod deverá gerar uma exeção" do
      FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => "<?xml version=\"1.0\" encoding=\"utf-8\"?><PagadorBoletoReturn xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"https://www.pagador.com.br/webservice/pagador\"><amount xsi:nil=\"true\" /><expirationDate xsi:nil=\"true\" /><returnCode>3</returnCode><message>Invalid payment method</message><status xsi:nil=\"true\" /></PagadorBoletoReturn>")

      expect {
        bill =  Braspag::Bill.new(@connection , {
            :orderId => 1,
            :amount => "0000",
            :paymentMethod => 10
          })
        bill.generate
      }.to raise_error(Braspag::Bill::InvalidPaymentMethod)
      FakeWeb.clean_registry

    end
    
    it "para amount deverá gerar uma exeção" do
      FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => "<?xml version=\"1.0\" encoding=\"utf-8\"?><PagadorBoletoReturn xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"https://www.pagador.com.br/webservice/pagador\"><amount xsi:nil=\"true\" /><expirationDate xsi:nil=\"true\" /><returnCode>1</returnCode><message>Invalid purchase amount</message><status xsi:nil=\"true\" /></PagadorBoletoReturn>")
      expect {
        bill =  Braspag::Bill.new(@connection , {
            :orderId => 1,
            :amount => 3,
            :paymentMethod => "-99"
          })
        bill.generate
      }.to raise_error(Braspag::Bill::InvalidAmount)
      FakeWeb.clean_registry

    end


    it "para qualquer erro desconhecido deverá gerar uma exeção" do
      FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/webservices/pagador/Boleto.asmx/CreateBoleto", :body => "<?xml version=\"1.0\" encoding=\"utf-8\"?><PagadorBoletoReturn xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns=\"https://www.pagador.com.br/webservice/pagador\"><amount xsi:nil=\"true\" /><expirationDate xsi:nil=\"true\" /><returnCode>1</returnCode><message>Invalid server</message><status xsi:nil=\"true\" /></PagadorBoletoReturn>")
      expect {
        bill =  Braspag::Bill.new(@connection , {
            :orderId => 1,
            :amount => 3,
            :paymentMethod => "10"
          })
        bill.generate
      }.to raise_error(Braspag::Bill::InvalidPost)
      FakeWeb.clean_registry
    end

  end
end
