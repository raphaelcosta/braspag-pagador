require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  before :each do
    @clazz = Braspag::Connection
  end

  it "deve inicializar dado um ambiente e o id da loja" do
    lambda { @clazz.new("gfwehj53h2njk", :test) }.should_not raise_error
  end

  it "deve inicializar dado um id da loja" do
    lambda { @clazz.new("gfwehj53h2njk") }.should_not raise_error
  end

  it "deve entender que o ambiente é produção quando nehum for especificado" do
    @clazz.new("fwefewfewfew").environment.should eql(Braspag::Production)
  end

  it "deve reconhecer a url do ambiente de teste" do
    @clazz.new("wegwegwe", :test).base_url.should eql(Braspag::Test::BASE_URL)
  end

  it "deve reconhecer a url do ambiente de produção" do
    @clazz.new("wegwegwe", :production).base_url.should eql(Braspag::Production::BASE_URL)
  end

  it "deve devolver o merchant id utilizado na conexão" do
    merchant_id = "fwefwefjkwe"
    @clazz.new(merchant_id).merchant_id.should eql(merchant_id)
  end
end
