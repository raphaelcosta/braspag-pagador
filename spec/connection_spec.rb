#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Connection do
  before :each do
    @clazz = Braspag::Connection
    @valid_merchant_id = "{12345678-1234-1234-1234-123456789000}"
  end

  it "deve gerar uma exceção quando :merchantId for maior que 38 caracteres" do
    merchant_id = (1..100).collect{"A"}.join
    lambda { @clazz.new(merchant_id) }.should raise_error
  end

  it "deve gerar uma exceção quando :merchantId for menor que 38 caracteres" do
    merchant_id = (1..37).collect{"B"}.join
    lambda { @clazz.new(merchant_id) }.should raise_error
  end

  it "deve gerar uma exceção quando :merchantId não seguir o formato {00000000-0000-0000-0000-000000000000}" do
    lambda { @clazz.new("0000000-0000-0000-0000-000000000000") }.should raise_error
    lambda { @clazz.new("{000000000000000000000000000000000000}") }.should raise_error

    lambda { @clazz.new(@valid_merchant_id) }.should_not raise_error
  end

  it "deve inicializar dado um ambiente e o id da loja" do
    lambda { @clazz.new(@valid_merchant_id, :test) }.should_not raise_error
  end

  it "deve inicializar dado um id da loja" do
    lambda { @clazz.new(@valid_merchant_id) }.should_not raise_error
  end

  it "deve entender que o ambiente é produção quando nehum for especificado" do
    @clazz.new(@valid_merchant_id).environment.should eql(Braspag::Production)
  end

   it "deve entender que o ambiente é teste quando for especificado staging" do
    @clazz.new(@valid_merchant_id, 'staging').environment.should eql(Braspag::Test)
  end

  it "deve reconhecer a url do ambiente de teste" do
    @clazz.new(@valid_merchant_id, :test).base_url.should eql(Braspag::Test::BASE_URL)
  end

  it "deve reconhecer a url do ambiente de produção" do
    @clazz.new(@valid_merchant_id, :production).base_url.should eql(Braspag::Production::BASE_URL)
  end

  it "deve devolver o merchant id utilizado na conexão" do
    @clazz.new(@valid_merchant_id).merchant_id.should eql(@valid_merchant_id)
  end

end
