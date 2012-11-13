require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
  
  let(:customer) do
    Braspag::Customer.new(:name => "W" * 21)
  end

  let(:order) do
    Braspag::Order.new(
      :id                => "um order id",
      :amount            => 1000.00,
      :payment_method    => Braspag::PAYMENT_METHOD[:eft_itau],
      :customer          => customer
    )
  end

  let(:eft) do
    Braspag::EFT.new(
      :crypto => Braspag::Crypto::NoCrypto.new
    )
  end
  
  let(:eft_with_encrypt) do
    Braspag::EFT.new(
      :crypto => Braspag::Crypto::Webservice.new
    )
  end
  
  context ".generate_eft" do
    it "should return active merchant response" do
      response = connection.generate_eft(order, eft)
      response.success?.should eq(true)
      response.message.should eq('OK')
    end
    
    it "should return active merchant response for encrypt error" do
      Braspag::Crypto::Webservice.any_instance.should_receive(:encrypt).and_raise('ERROR')
      response = connection.generate_eft(order, eft_with_encrypt)
      response.success?.should eq(false)
      response.message.should eq('ERROR')
    end
    
    it "should popule eft code a html form" do
      response = connection.generate_eft(order, eft)
      
      eft.code.should eq("<form id='form_tef_um order id' name='form_tef_um order id' action='https://homologacao.pagador.com.br/pagador/passthru.asp' method='post'><input type='text' name='Id_Loja' value='{12345678-1234-1234-1234-123456789000}' /><input type='text' name='VALOR' value='1000,00' /><input type='text' name='CODPAGAMENTO' value='12' /><input type='text' name='VENDAID' value='um order id' /><input type='text' name='NOME' value='WWWWWWWWWWWWWWWWWWWWW' /></form><script type='text/javascript' charset='utf-8'>document.forms['form_tef_um order id'].submit();</script>")
    end

    it "should populate eft code a html form when crypto strategy is given" do
      Braspag::Crypto::Webservice.any_instance.should_receive(:encrypt).and_return('vei na boa')
      response = connection.generate_eft(order, eft_with_encrypt)
      
      eft_with_encrypt.code.should eq("<form id='form_tef_um order id' name='form_tef_um order id' action='https://homologacao.pagador.com.br/pagador/passthru.asp' method='post'><input type='text' name='Id_Loja' value='{12345678-1234-1234-1234-123456789000}' /><input type='text' name='crypt' value='vei na boa' /></form><script type='text/javascript' charset='utf-8'>document.forms['form_tef_um order id'].submit();</script>")
    end
  end
end


describe Braspag::EFT do
  
  context "on generate" do
    it "should not allow blank for crypto" do
      subject.crypto = ''
      subject.valid?(:generate)
      subject.errors.messages[:crypto].should include("can't be blank")
    end

    it "should not allow invalid crypto" do
      subject.crypto = 1234
      subject.valid?(:generate)
      subject.errors.messages[:crypto].should include("invalid crypto")
    end
    
    [ Braspag::Crypto::Webservice.new, 
      Braspag::Crypto::NoCrypto.new
    ].each do |crypto|
      it "should accept valid crypto: #{crypto.class}" do
        subject.crypto = crypto
        subject.valid?(:generate)
        subject.errors.messages[:crypto].should be(nil)
      end
    end
  end
  
end