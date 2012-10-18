require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Response do
  it ".message" do
    response = Braspag::Response.new
    response.message = "bla"
    response.message.should eq("bla")
  end

  it ".code" do
    response = Braspag::Response.new
    response.code = "bla"
    response.code.should eq("bla")
  end
  
  describe ".success?" do
    it "should response true" do
      response = Braspag::Response.new
      response.success?.should be(true)
    end
  end
end