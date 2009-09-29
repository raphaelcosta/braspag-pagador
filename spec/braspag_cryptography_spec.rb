require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "BraspagCryptography" do
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
