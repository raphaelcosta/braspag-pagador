#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Order do

  let!(:merchant_id) {"{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"}
  let!(:connection) {Braspag::Connection.new(merchant_id, :test)}

  describe "#status" do

    it "should raise an error when no connection is given" do
      expect {
        Braspag::Order.status("", nil)
      }.to raise_error(Braspag::InvalidConnection)
    end

    it "should raise an error when no order_id is given" do
      expect {
        Braspag::Order.status(connection, nil)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when order_id is empty" do
      expect {
        Braspag::Order.status(connection, "")
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when order_id is more than 50 characters" do
      expect {
        Braspag::Order.status(connection, "1" * 51)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    context "with incorrect data" do

      it "should raise an error for invalid data" do
        xml = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
             xmlns:xsd="http://www.w3.org/2001/XMLSchema"
             xsi:nil="true"
             xmlns="http://www.pagador.com.br/" />
        EOXML

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/pagador/webservice/pedido.asmx/GetDadosPedido")

        expect {
          Braspag::Order.status(connection, "sadpoakjspodqdouq09wduwq")
        }.to raise_error(Braspag::Order::InvalidData)

        new_connection = Braspag::Connection.new("{12345678-1234-1234-1234-123456789012}", :test)

        expect {
          Braspag::Order.status(new_connection, "asdnasdniousa")
        }.to raise_error(Braspag::Order::InvalidData)

        FakeWeb.clean_registry
      end

    end

    context "with correct data" do

      let!(:order_info) {
        xml = <<-EOXML
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

        FakeWeb.register_uri(:post, "#{Braspag::Test::BASE_URL}/pagador/webservice/pedido.asmx/GetDadosPedido")
        order_info = Braspag::Order.status(connection, "12345")
        FakeWeb.clean_registry
        order_info
      }

      it "should return a Hash" do
        order_info.should be_kind_of Hash
      end

      it "should return a Hash with :status key" do
        order_info[:status].should_not be_nil
        order_info[:status].should == :paid
      end

      it "should return a Hash with :authorization_code key" do
        order_info[:authorization_code].should_not be_nil
      end

    end

  end

end

