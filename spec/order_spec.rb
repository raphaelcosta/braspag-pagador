#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Order do
  let!(:braspag_url) { "https://homologacao.pagador.com.br" }

  describe "#status" do
    it "should raise an error when no order_id is given" do
      expect {
        Braspag::Order.status(nil)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when order_id is empty" do
      expect {
        Braspag::Order.status("")
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error when order_id is more than 50 characters" do
      expect {
        Braspag::Order.status("1" * 51)
      }.to raise_error(Braspag::InvalidOrderId)
    end

    it "should raise an error for incorrect data" do
      xml = <<-EOXML
<?xml version="1.0" encoding="utf-8"?>
<DadosPedido xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
           xmlns:xsd="http://www.w3.org/2001/XMLSchema"
           xsi:nil="true"
           xmlns="http://www.pagador.com.br/" />
      EOXML

      FakeWeb.register_uri(:post, "#{braspag_url}/pagador/webservice/pedido.asmx/GetDadosPedido",
        :body => xml)

      expect {
        Braspag::Order.status("sadpoakjspodqdouq09wduwq")
      }.to raise_error(Braspag::Order::InvalidData)


      expect {
        Braspag::Order.status("asdnasdniousa")
      }.to raise_error(Braspag::Order::InvalidData)

      FakeWeb.clean_registry
    end

    context "with correct data" do

      let(:order_info) {
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

        FakeWeb.register_uri(:post, "#{braspag_url}/pagador/webservice/pedido.asmx/GetDadosPedido",
          :body => xml)
        order_info = Braspag::Order.status("12345")
        FakeWeb.clean_registry
        order_info
      }

      it "should return a Hash" do
        order_info.should be_kind_of Hash
      end

      {
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
      }.each do |key, value|

        it "should return a Hash with :#{key.to_s} key" do
          order_info[key].should == value
        end
      end
    end
  end
end
