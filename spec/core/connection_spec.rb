# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  
  it "should accept a valid merchant" do
    expect {
      Braspag::Connection.new(:merchant_id => merchant_id)
    }.to_not raise_error(Braspag::Connection::InvalidMerchantId)
  end
  
  it "should raise error with invalid merchant" do
    expect {
      Braspag::Connection.new(:merchant_id => "INVALID")
    }.to raise_error(Braspag::Connection::InvalidMerchantId)
  end
  
  [:homologation, :production].each do |env|
    it "should accept #{env} environment" do
      expect {
        Braspag::Connection.new(:merchant_id => merchant_id, :environment => env)
      }.to_not raise_error(Braspag::Connection::InvalidEnvironment)
    end
  end
  
  it "should raise error with invalid environment" do
    expect {
      Braspag::Connection.new(:merchant_id => merchant_id, :environment => :bla)
    }.to raise_error(Braspag::Connection::InvalidEnvironment)
  end
  
  describe  ".production?" do
    it "should return true" do
      connection = Braspag::Connection.new(:merchant_id => merchant_id, :environment => :production)
      connection.production?.should be(true)
    end
    
    it "should return false" do
      connection = Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)
      connection.production?.should be(false)
    end
  end
  
  describe  ".homologation?" do
    it "should return true" do
      connection = Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)
      connection.homologation?.should be(true)
    end
    
    it "should return false" do
      connection = Braspag::Connection.new(:merchant_id => merchant_id, :environment => :production)
      connection.homologation?.should be(false)
    end
  end
  
  describe ".url_for" do
    let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
    let(:braspag_production_url) { "https://transaction.pagador.com.br" }
    let(:braspag_homologation_protected_card_url) { "https://homologacao.braspag.com.br/services/testenvironment" }
    let(:braspag_production_protected_card_url) { "https://cartaoprotegido.braspag.com.br/Services" }
    
    it "should return the correct credit card creation url when connection environment is homologation" do
      connection = Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)
      connection.url_for(:authorize).should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/Authorize"
      connection.url_for(:capture).should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/Capture"
      connection.url_for(:void).should == "#{braspag_homologation_url}/webservices/pagador/Pagador.asmx/VoidTransaction"
      connection.url_for(:generate_billet).should == "#{braspag_homologation_url}/webservices/pagador/Boleto.asmx/CreateBoleto"
      connection.url_for(:generate_eft).should == "#{braspag_homologation_url}/pagador/passthru.asp"
      connection.url_for(:info_billet).should == "#{braspag_homologation_url}/pagador/webservice/pedido.asmx/GetDadosBoleto"
      connection.url_for(:info_card).should == "#{braspag_homologation_url}/pagador/webservice/pedido.asmx/GetDadosCartao"
      connection.url_for(:info).should == "#{braspag_homologation_url}/pagador/webservice/pedido.asmx/GetDadosPedido"
      connection.url_for(:encrypt).should == "#{braspag_homologation_url}/BraspagGeneralService/BraspagGeneralService.asmx"
      connection.url_for(:archive_card).should == "#{braspag_homologation_protected_card_url}/CartaoProtegido.asmx?wsdl"
      connection.url_for(:get_card).should == "#{braspag_homologation_protected_card_url}/CartaoProtegido.asmx/GetCreditCard"
      connection.url_for(:recurrency).should == "#{braspag_homologation_protected_card_url}/CartaoProtegido.asmx?wsdl"
    end

    it "should return the correct credit card creation url when connection environment is production" do
      connection = Braspag::Connection.new(:merchant_id => merchant_id, :environment => :production)
      connection.url_for(:authorize).should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/Authorize"
      connection.url_for(:capture).should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/Capture"
      connection.url_for(:void).should == "#{braspag_production_url}/webservices/pagador/Pagador.asmx/VoidTransaction"
      connection.url_for(:generate_billet).should == "#{braspag_production_url}/webservices/pagador/Boleto.asmx/CreateBoleto"
      connection.url_for(:generate_eft).should == "#{braspag_production_url}/pagador/passthru.asp"
      connection.url_for(:info_billet).should == "#{braspag_production_url}/webservices/pagador/pedido.asmx/GetDadosBoleto"
      connection.url_for(:info_card).should == "#{braspag_production_url}/webservices/pagador/pedido.asmx/GetDadosCartao"
      connection.url_for(:info).should == "#{braspag_production_url}/webservices/pagador/pedido.asmx/GetDadosPedido"
      connection.url_for(:encrypt).should == "#{braspag_production_url}/BraspagGeneralService/BraspagGeneralService.asmx"
      connection.url_for(:archive_card).should == "#{braspag_production_protected_card_url}/CartaoProtegido.asmx?wsdl"
      connection.url_for(:get_card).should == "#{braspag_production_protected_card_url}/CartaoProtegido.asmx/GetCreditCard"
      connection.url_for(:recurrency).should == "#{braspag_production_protected_card_url}/CartaoProtegido.asmx?wsdl"
    end
  end
end
