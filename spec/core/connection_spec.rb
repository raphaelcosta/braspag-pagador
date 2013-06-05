# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe BraspagPagador::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }

  it "should accept a valid merchant" do
    expect {
      BraspagPagador::Connection.new(:merchant_id => merchant_id)
    }.to_not raise_error(BraspagPagador::Connection::InvalidMerchantId)
  end

  it "should raise error with invalid merchant" do
    expect {
      BraspagPagador::Connection.new(:merchant_id => "INVALID")
    }.to raise_error(BraspagPagador::Connection::InvalidMerchantId)
  end

  [:homologation, :production].each do |env|
    it "should accept #{env} environment" do
      expect {
        BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => env)
      }.to_not raise_error(BraspagPagador::Connection::InvalidEnvironment)
    end
  end

  it "should raise error with invalid environment" do
    expect {
      BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :bla)
    }.to raise_error(BraspagPagador::Connection::InvalidEnvironment)
  end

  describe  ".production?" do
    it "should return true" do
      connection = BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :production)
      connection.production?.should be(true)
    end

    it "should return false" do
      connection = BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :homologation)
      connection.production?.should be(false)
    end
  end

  describe  ".homologation?" do
    it "should return true" do
      connection = BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :homologation)
      connection.homologation?.should be(true)
    end

    it "should return false" do
      connection = BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :production)
      connection.homologation?.should be(false)
    end
  end

  describe ".url_for" do
    let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
    let(:braspag_production_url) { "https://transaction.pagador.com.br" }
    let(:braspag_homologation_protected_card_url) { "https://homologacao.braspag.com.br/services/testenvironment" }
    let(:braspag_production_protected_card_url) { "https://cartaoprotegido.braspag.com.br/Services" }

    it "should return the correct credit card creation url when connection environment is homologation" do
      connection = BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :homologation)
      connection.url_for(:authorize).should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/Authorize"
      connection.url_for(:capture).should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/Capture"
      connection.url_for(:void).should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/VoidTransaction"
      connection.url_for(:generate_billet).should == "#{braspag_homologation_url}/webservices/pagador/Boleto.asmx/CreateBoleto"
      connection.url_for(:generate_eft).should == "#{braspag_homologation_url}/pagador/passthru.asp"
      connection.url_for(:info_billet).should == "#{braspag_homologation_url}/pagador/webservice/pedido.asmx/GetDadosBoleto"
      connection.url_for(:info_credit_card).should == "#{braspag_homologation_url}/pagador/webservice/pedido.asmx/GetDadosCartao"
      connection.url_for(:info).should == "#{braspag_homologation_url}/pagador/webservice/pedido.asmx/GetDadosPedido"
      connection.url_for(:encrypt).should == "#{braspag_homologation_url}/BraspagPagadorGeneralService/BraspagPagadorGeneralService.asmx"
      connection.url_for(:archive_card).should == "#{braspag_homologation_protected_card_url}/CartaoProtegido.asmx?wsdl"
      connection.url_for(:get_card).should == "#{braspag_homologation_protected_card_url}/CartaoProtegido.asmx/GetCreditCard"
      connection.url_for(:recurrency).should == "#{braspag_homologation_protected_card_url}/CartaoProtegido.asmx?wsdl"
    end

    it "should return the correct credit card creation url when connection environment is production" do
      connection = BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :production)
      connection.url_for(:authorize).should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/Authorize"
      connection.url_for(:capture).should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/Capture"
      connection.url_for(:void).should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/VoidTransaction"
      connection.url_for(:generate_billet).should == "#{braspag_production_url}/webservices/pagador/Boleto.asmx/CreateBoleto"
      connection.url_for(:generate_eft).should == "#{braspag_production_url}/pagador/passthru.asp"
      connection.url_for(:info_billet).should == "#{braspag_production_url}/webservices/pagador/pedido.asmx/GetDadosBoleto"
      connection.url_for(:info_credit_card).should == "#{braspag_production_url}/webservices/pagador/pedido.asmx/GetDadosCartao"
      connection.url_for(:info).should == "#{braspag_production_url}/webservices/pagador/pedido.asmx/GetDadosPedido"
      connection.url_for(:encrypt).should == "#{braspag_production_url}/BraspagPagadorGeneralService/BraspagPagadorGeneralService.asmx"
      connection.url_for(:archive_card).should == "#{braspag_production_protected_card_url}/CartaoProtegido.asmx?wsdl"
      connection.url_for(:get_card).should == "#{braspag_production_protected_card_url}/CartaoProtegido.asmx/GetCreditCard"
      connection.url_for(:recurrency).should == "#{braspag_production_protected_card_url}/CartaoProtegido.asmx?wsdl"
    end
  end

  describe ".post" do
    it "should convert data" do
      connection = BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :homologation)

      mock1 = mock
      mock2 = mock
      resp = mock
      convert_to = mock

      connection.should_receive(:convert).with(
        :info,
        :to,
        [mock1, mock2]
      ).and_return(convert_to)

      connection.should_receive(:convert).with(
        :info,
        :from,
        [mock1, mock2, resp]
      )

      BraspagPagador::Poster.any_instance.should_receive(:do_post).with(
        :info,
        convert_to
      ).and_return(resp)

      connection.post(:info, mock1, mock2)
    end
  end

  describe ".convert" do
    let (:connection) { BraspagPagador::Connection.new(:merchant_id => merchant_id, :environment => :homologation) }
    {
      :authorize => BraspagPagador::CreditCard,
      :void => BraspagPagador::CreditCard,
      :capture => BraspagPagador::CreditCard,
      :archive_card => BraspagPagador::CreditCard,
      :get_card => BraspagPagador::CreditCard,
      :recurrency => BraspagPagador::CreditCard,
      :generate_billet => BraspagPagador::Billet,
      :generate_eft => BraspagPagador::EFT,
      :info_billet => BraspagPagador::Order,
      :info_credit_card => BraspagPagador::Order,
      :info => BraspagPagador::Order,
      :encrypt => BraspagPagador::Crypto::Webservice
    }.each do |method_name, kclass|
      it "should call method when convert #{method_name} to #{kclass}" do
        args = [mock, mock]
        kclass.should_receive("to_#{method_name}".to_sym).with(connection, args[0], args[1])
        connection.convert(method_name, :to, args)
      end
    end
  end
end
