#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Crypto::JarWebservice do
  let!(:crypt) {Braspag::Crypto::JarWebservice}
  let! (:key) {"5u0ZN5qk8eQNuuGPHrcsk0rfi7YclF6s+ZXCE+G4uG4ztfRJrrOALlf81ra7k7p7"}

  pending "when encrypt data" do

      it "should return a string" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/encrypt.json",
          :body => <<-EOJSON
          {"encrypt":"5u0ZN5qk8eQNuuGPHrcsk0rfi7YclF6s+ZXCE+G4uG4ztfRJrrOALlf81ra7k7p7"}
          EOJSON
        )

        crypt.encrypt(:nome => "Chapulin", :sobrenome => "Colorado").should == key
      end

      it "should raise a error with invalid params" do
        expect {
          crypt.encrypt(9999)
        }.to raise_error(Braspag::IncompleteParams)
      end

      it "should raise an error with invalid params after process" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/encrypt.json",
          :body => <<-EOJSON
          {
          	"msg" : "INVALID FORMAT"
          }
          EOJSON
        )

        expect {
          crypt.encrypt(:venda => "value")
        }.to raise_error(Braspag::IncompleteParams)
      end

      it "should raise an error with invalid params after process" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/encrypt.json",
          :body => <<-EOJSON
INVALIDO
          EOJSON
        )

        expect {
          crypt.encrypt(:venda => "value")
        }.to raise_error(Braspag::UnknownError)
      end

      it "should raise an error with invalid params after process" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/encrypt.json",
          :body => <<-EOJSON
          {
          	"msg" : "INVALID FIELDS"
          }
          EOJSON
        )

        expect {
          crypt.encrypt(:venda => nil)
        }.to raise_error(Braspag::IncompleteParams)
      end

      it "should raise an error with invalid crypt key" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/encrypt.json",
          :body => <<-EOJSON
          {
          	"msg" : "INVALID KEY"
          }
          EOJSON
        )

        expect {
          crypt.encrypt(:venda => "value")
        }.to raise_error(Braspag::InvalidCryptKey)
      end

  end

  pending "when decrypt data" do

      it "should return a hash" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/decrypt.json",
          :body => <<-EOJSON
          {"fields":{"nome":"Chapulin","sobrenome":"Colorado"}}
          EOJSON
        )

        crypt.decrypt(key, [:nome, :sobrenome])[:nome].should eql("Chapulin")
      end

      it "should raise a error with invalid encrypted key" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/decrypt.json",
          :body => <<-EOJSON
          {
          	"msg" : "INVALID ENCRYPTED STRING"
          }
          EOJSON
        )

        expect {
          crypt.decrypt("1", [:nome, :sobrenome])
        }.to raise_error(Braspag::InvalidEncryptedKey)
      end

      it "should raise a error with invalid encrypted key" do
        expect {
          crypt.decrypt(1, [:nome, :sobrenome])
        }.to raise_error(Braspag::InvalidEncryptedKey)
      end


      it "should raise a error with invalid fields" do
        expect {
          crypt.decrypt(key, 9999)
        }.to raise_error(Braspag::IncompleteParams)
      end

      it "should raise a error with invalid fields" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/decrypt.json",
          :body => <<-EOJSON
          {
          	"msg" : "INVALID FIELDS"
          }
          EOJSON
        )

        expect {
          crypt.decrypt(key, [:nome, :sobrenome])
        }.to raise_error(Braspag::IncompleteParams)
      end

      it "should raise an error with invalid params after process" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/decrypt.json",
          :body => <<-EOJSON
INVALIDO
          EOJSON
        )


        expect {
          crypt.decrypt(key, [:nome, :sobrenome])
        }.to raise_error(Braspag::UnknownError)
      end

      it "should raise an error with invalid crypt key" do
        FakeWeb.register_uri(
          :post,
          "http://localhost:9292/v1/decrypt.json",
          :body => <<-EOJSON
          {
          	"msg" : "INVALID KEY"
          }
          EOJSON
        )

        expect {
          crypt.decrypt(key, [:nome, :sobrenome])
        }.to raise_error(Braspag::InvalidCryptKey)
      end

  end
end