# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:environment) { :test }
  
  it "should accept a valid merchant" do
    expect {
      Braspag::Connection.new(merchant_id, :bla)
    }.to_not raise_error(Braspag::Connection::InvalidMerchantId)
  end
  
  it "should raise error with invalid merchant" do
    expect {
      Braspag::Connection.new("INVALID", :bla)
    }.to raise_error(Braspag::Connection::InvalidMerchantId)
  end
  
  [:homologation, :production].each do |env|
    it "should accept #{env} environment" do
      expect {
        Braspag::Connection.new(merchant_id, env)
      }.to_not raise_error(Braspag::Connection::InvalidEnvironment)
    end
  end
  
  it "should raise error with invalid environment" do
    expect {
      Braspag::Connection.new(merchant_id, :bla)
    }.to raise_error(Braspag::Connection::InvalidEnvironment)
  end
  
  describe  ".production?" do
    it "should return true" do
      connection = Braspag::Connection.new(merchant_id, :production)
      connection.production?.should be(true)
    end
    
    it "should return false" do
      connection = Braspag::Connection.new(merchant_id, :homologation)
      connection.production?.should be(false)
    end
  end
  
  describe  ".homologation?" do
    it "should return true" do
      connection = Braspag::Connection.new(merchant_id, :homologation)
      connection.homologation?.should be(true)
    end
    
    it "should return false" do
      connection = Braspag::Connection.new(merchant_id, :production)
      connection.homologation?.should be(false)
    end
  end

  

end
