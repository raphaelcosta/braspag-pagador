# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:crypto_key) { "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}" }
  let(:crypto_url) { "http://localhost:9292" }

  let(:braspag_environment) { "homologation" }

  let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
  let(:braspag_production_url) { "https://transaction.pagador.com.br" }

  let(:braspag_config) do
    config = {}
    config[ENV["RACK_ENV"]] = {
      "environment" => braspag_environment,
      "merchant_id" => merchant_id,
      "crypto_key"  => crypto_key,
      "crypto_url"  => crypto_url
    }
    config
  end

  before(:all) do
    @connection = Braspag::Connection.clone
  end

  context "changing default config file path" do
    before :each do
      @original_path = Braspag.config_file_path
    end

    after :each do
      Braspag.config_file_path = @original_path
    end

    it "should read config from a different path when specified" do
      connection = Braspag::Connection.clone

      Braspag.config_file_path = '/some/crazy/path'

      YAML.should_receive(:load_file).
        with("/some/crazy/path").
        and_return(braspag_config)

      connection.instance
    end
  end

  it "should read config/braspag.yml when alloc first instance" do
    YAML.should_receive(:load_file)
        .with("config/braspag.yml")
        .and_return(braspag_config)
    @connection.instance
  end

  it "should not read config/braspag.yml when alloc a second instance" do
    YAML.should_not_receive(:load_file)
    @connection.instance
  end

  it "should generate an exception when RACK_ENV is nil" do
    ENV.should_receive(:[])
       .with("RACK_ENV")
       .and_return(nil)

    expect {
      Braspag::Connection.clone.instance
    }.to raise_error Braspag::Connection::InvalidEnv
  end

  it "should generate an exception when RACK_ENV is empty" do
    ENV.should_receive(:[])
       .twice
       .with("RACK_ENV")
       .and_return("")

    expect {
      Braspag::Connection.clone.instance
    }.to raise_error Braspag::Connection::InvalidEnv
  end

  it "should generate an exception when merchant_id is not in a correct format" do
    braspag_config[ENV["RACK_ENV"]]["merchant_id"] = "A" * 38

    YAML.should_receive(:load_file)
        .with("config/braspag.yml")
        .and_return(braspag_config)

    expect {
      Braspag::Connection.clone.instance
    }.to raise_error Braspag::Connection::InvalidMerchantId
  end

  it { @connection.instance.crypto_url.should == crypto_url }
  it { @connection.instance.crypto_key.should == crypto_key }
  it { @connection.instance.merchant_id.should == merchant_id }

  [:braspag_url, :merchant_id, :crypto_url, :crypto_key,
    :options, :environment].each do |attribute|

    it { @connection.instance.should respond_to(attribute) }

  end

  describe "#production?" do
    it "should return true when environment is production" do
      braspag_config[ENV["RACK_ENV"]]["environment"] = "production"

      YAML.should_receive(:load_file)
          .and_return(braspag_config)

      Braspag::Connection.clone.instance.production?.should be_true
    end

    it "should return false when environment is not production" do
      braspag_config[ENV["RACK_ENV"]]["environment"] = "homologation"

      YAML.should_receive(:load_file)
          .and_return(braspag_config)

      Braspag::Connection.clone.instance.production?.should be_false
    end
  end

  describe "#homologation?" do
    it "should return true when environment is homologation" do
      braspag_config[ENV["RACK_ENV"]]["environment"] = "homologation"

      YAML.should_receive(:load_file)
          .and_return(braspag_config)

      Braspag::Connection.clone.instance.homologation?.should be_true
    end

    it "should return false when environment is not homologation" do
      braspag_config[ENV["RACK_ENV"]]["environment"] = "production"

      YAML.should_receive(:load_file)
          .and_return(braspag_config)

      Braspag::Connection.clone.instance.homologation?.should be_false
    end
  end

  describe "#braspag_url" do
    context "when environment is homologation" do
      it "should return the Braspag homologation url" do
        braspag_config[ENV["RACK_ENV"]]["environment"] = "homologation"

        YAML.should_receive(:load_file)
            .and_return(braspag_config)

        connection = Braspag::Connection.clone.instance
        connection.braspag_url.should == braspag_homologation_url
      end
    end

    context "when environment is production" do
      it "should return the Braspag production url" do
        braspag_config[ENV["RACK_ENV"]]["environment"] = "production"

        YAML.should_receive(:load_file)
            .and_return(braspag_config)

        connection = Braspag::Connection.clone.instance
        connection.braspag_url.should == braspag_production_url
      end
    end
  end
end
