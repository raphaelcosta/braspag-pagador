#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Connection do
  let!(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let!(:braspag_url) { "https://homologacao.pagador.com.br" }

  let!(:mock_for_connection) {
    mock = {}
    mock[ENV["RACK_ENV"]] = {
      "merchant_id" => merchant_id,
      "braspag_url" => braspag_url
    }
    mock
  }

  before(:all) do
    @connection = Braspag::Connection.clone
  end

  it "should read config/braspag.yml when alloc first instance" do
    YAML.should_receive(:load_file).with("config/braspag.yml").and_return(mock_for_connection)
    @connection.instance
  end

  it "should not read config/braspag.yml when alloc second instance" do
    YAML.should_not_receive(:load_file)
    @connection.instance
  end

  it "should generate exception when RACK_ENV is nil" do
    backup = ENV["RACK_ENV"].clone
    ENV["RACK_ENV"] = nil
    expect {
      other_connection = Braspag::Connection.clone
      other_connection.instance
    }.should raise_error(Braspag::Connection::InvalidEnv)
    ENV["RACK_ENV"] = backup
  end

  it "should generate exception when RACK_ENV is empty" do
    backup = ENV["RACK_ENV"].clone
    ENV["RACK_ENV"] = ""
    expect {
      other_connection = Braspag::Connection.clone
      other_connection.instance
    }.should raise_error(Braspag::Connection::InvalidEnv)
    ENV["RACK_ENV"] = backup
  end


  it "should generate exception when :merchant_id is more than 38 chars" do
    mock_merchant = mock_for_connection
    mock_merchant[ENV["RACK_ENV"]]["merchant_id"] = (1..100).collect{"A"}.join
    YAML.should_receive(:load_file).with("config/braspag.yml").and_return(mock_merchant)
    other_connection = Braspag::Connection.clone

    expect { other_connection.instance }.should raise_error(Braspag::Connection::InvalidMerchantId)
  end

  it "should generate exception when :merchant_id is less than 38 chars" do
    mock_merchant = mock_for_connection
    mock_merchant[ENV["RACK_ENV"]]["merchant_id"] = (1..37).collect{"B"}.join
    YAML.should_receive(:load_file).with("config/braspag.yml").and_return(mock_merchant)
    other_connection = Braspag::Connection.clone

    expect { other_connection.instance }.should raise_error(Braspag::Connection::InvalidMerchantId)
  end

  context "should generate exception when :merchant_id not follow format {00000000-0000-0000-0000-000000000000}" do
    it "0000000-0000-0000-0000-000000000000" do
     mock_merchant = mock_for_connection
     mock_merchant[ENV["RACK_ENV"]]["merchant_id"] = "0000000-0000-0000-0000-000000000000"
     YAML.should_receive(:load_file).with("config/braspag.yml").and_return(mock_merchant)
     other_connection = Braspag::Connection.clone
     expect { other_connection.instance }.should raise_error(Braspag::Connection::InvalidMerchantId)
    end

    it "{000000000000000000000000000000000000}" do
     mock_merchant = mock_for_connection
     mock_merchant[ENV["RACK_ENV"]]["merchant_id"] = "{000000000000000000000000000000000000}"
     YAML.should_receive(:load_file).with("config/braspag.yml").and_return(mock_merchant)
     other_connection = Braspag::Connection.clone
     expect { other_connection.instance }.should raise_error(Braspag::Connection::InvalidMerchantId)
    end
  end

  it "should :merchant_id has correct in instance" do
    new_connection = @connection.instance
    new_connection.merchant_id.should == merchant_id
  end

  it "should generate exception when :braspag_url is nil" do
    mock_merchant = mock_for_connection
    mock_merchant[ENV["RACK_ENV"]]["braspag_url"] = nil
    YAML.should_receive(:load_file).with("config/braspag.yml").and_return(mock_merchant)
    other_connection = Braspag::Connection.clone

    expect { other_connection.instance }.should raise_error(Braspag::Connection::InvalidBraspagUrl)
  end

  it "should generate exception when :braspag_url is empty" do
    mock_merchant = mock_for_connection
    mock_merchant[ENV["RACK_ENV"]]["braspag_url"] = ""
    YAML.should_receive(:load_file).with("config/braspag.yml").and_return(mock_merchant)
    other_connection = Braspag::Connection.clone

    expect { other_connection.instance }.should raise_error(Braspag::Connection::InvalidBraspagUrl)
  end

  it "should :braspag_url has correct in instance" do
    new_connection = @connection.instance
    new_connection.braspag_url.should == braspag_url
  end
end
