#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Bill do
  before do
    @merchant_id = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
    @connection = Braspag::Connection.new(@merchant_id, :test)
  end

  context "consistência" do

    it "para connection" do
      expect {
        Braspag::Bill.new("11")
      }.to raise_error(Braspag::Bill::InvalidConnection)
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

  context "com dados corretos ao gerar um boleto" do
    before do
      @bill =  Braspag::Bill.new(@connection , {
            :orderId => 1,
            :amount => 3,
            :paymentMethod => 10
          })
      @response = @bill.generate
    end

    it "deverá retornar url p/ acesso ao boleto" do
      @response[:url].should == "url_do_boleto"
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
      @response[:number].should == "125"
    end

    it "deverá retornar número sequencial do boleto" do
      @response[:number].should == "125"
    end

    it "deverá retornar data de expiração do boleto" do
      @response[:expirationDate].should == "2001"
    end

  end


  context "com dados incorretos ao gerar um boleto" do
    pending "para merchant_id"
    pending "para order_id"
    pending "para paymentMethod"
    pending "para amount"
  end



end
