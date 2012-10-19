require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
  let(:braspag_production_url) { "https://transaction.pagador.com.br" }
  let(:merchant_id) { "um id qualquer" }

  pending ".generate_eft" do
    let(:params) do
      {
        :order_id => 11,
        :amount => 3,
        :payment_method => :bradesco,
        :installments => 1,
        :has_interest => 0
      }
    end

    let(:params_with_merchant_id) do
      params.merge!(:merchant_id => merchant_id)
    end

    let(:action_url) { "https://bla.com/foo/bar/baz" }

    before do
      @connection.should_receive(:merchant_id)

      Braspag::Eft.should_receive(:action_url)
                  .and_return(action_url)

      Braspag::Eft.should_receive(:normalize_params)
                  .with(params_with_merchant_id)
                  .and_return(params_with_merchant_id)

      Braspag::Eft.should_receive(:check_params)
                  .and_return(true)
    end

    it "should return a html form" do
      html = "<form id=\"form_tef_11\" name=\"form_tef_11\" action=\"#{action_url}\" method=\"post\">" +
             "<input type=\"text\" name=\"Id_Loja\" value=\"#{merchant_id}\" />" +
             '<input type="text" name="VENDAID" value="11" />' +
             '<input type="text" name="nome" value="" />' +
             '<input type="text" name="CPF" value="" />' +
             '<input type="text" name="VALOR" value="3,00" />' +
             '<input type="text" name="CODPAGAMENTO" value="11" />' +
             '<input type="text" name="PARCELAS" value="1" />' +
             '<input type="text" name="TIPOPARCELADO" value="0" />' +
             '</form>' +
             '<script type="text/javascript" charset="utf-8">document.forms["form_tef_11"].submit();</script>'

      Braspag::Eft.generate(params).should == html
    end

    it "should return a html form when crypto strategy is given" do
      crypto = mock
      crypto.should_receive(:encrypt)
            .with(a_kind_of(Hash))
            .and_return("vei na boa")

      html = "<form id=\"form_tef_11\" name=\"form_tef_11\" action=\"#{action_url}\" method=\"post\">" +
             "<input type=\"text\" name=\"Id_Loja\" value=\"#{merchant_id}\" />" +
             '<input type="text" name="crypt" value="vei na boa" />' +
             '</form>' +
             '<script type="text/javascript" charset="utf-8">document.forms["form_tef_11"].submit();</script>'

      Braspag::Eft.generate(params, crypto).should == html
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
      Braspag::Crypto::NoCrypto.new, 
      Braspag::Crypto::JarWebservice.new(
        :url => "http://0.0.0.0:9292",
        :key => "123456123456"
      )
    ].each do |crypto|
      it "should accept valid crypto: #{crypto.class}" do
        subject.crypto = crypto
        subject.valid?(:generate)
        subject.errors.messages[:crypto].should be(nil)
      end
    end
  end
  
end