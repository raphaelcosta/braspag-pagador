require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BraspagCryptography" do
  MERCHANT_ID = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
  BASE_URL = 'https://homologacao.pagador.com.br'

  before do
    @braspag_cryptography = BraspagCryptography.new BASE_URL, MERCHANT_ID
    @plain_text = "XYZ"
    @encripted_text = "XXXXX"
  end

  it "should encrypt request" do
    result = @braspag_cryptography.encrypt_request!(@plain_text)
    result.should == @encripted_text
  end

  it "should decrypt request" do
    result = @braspag_cryptography.decrypt_request!(@encripted_text)
    result.should == @plain_text
  end
end
