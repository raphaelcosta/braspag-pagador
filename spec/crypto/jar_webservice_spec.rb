#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Crypto::JarWebservice do
  let!(:crypto_key) {"{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"}
  let!(:uri) {"http://localhost:9292"}
  let!(:crypt) {Braspag::Crypto::JarWebservice.new(crypto_key, uri)}
  let! (:key) {"5u0ZN5qk8eQNuuGPHrcsk0rfi7YclF6s+ZXCE+G4uG4ztfRJrrOALlf81ra7k7p7"}
  
    context "ao encriptar dados" do
      before(:each) do
        FakeWeb.register_uri(:post, 
        "http://localhost:9292/v1/encrypt.json", 
        :body => <<-EOJSON
        {"encrypt":"5u0ZN5qk8eQNuuGPHrcsk0rfi7YclF6s+ZXCE+G4uG4ztfRJrrOALlf81ra7k7p7"}
        EOJSON
        )
      end

      after(:each) do
        FakeWeb.clean_registry
      end
      
      it "deve devolver o resultado como uma string" do
        crypt.encrypt(:nome => "Chapulin", :sobrenome => "Colorado").should == key
      end
    end

    context "ao decriptar os dados" do
      before(:each) do
        FakeWeb.register_uri(:post, 
        "http://localhost:9292/v1/decrypt.json", 
        :body => <<-EOJSON
        {"fields":{"nome":"Chapulin","sobrenome":"Colorado"}}
        EOJSON
        )
      end

      after(:each) do
        FakeWeb.clean_registry
      end

      
      it "deve retornar o resultado como um mapa de valores" do
        crypt.decrypt(key, [:nome, :sobrenome])[:nome].should eql("Chapulin")
      end
    end
end