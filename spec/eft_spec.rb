require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Eft do
  let(:braspag_homologation_url) { "https://homologacao.pagador.com.br" }
  let(:braspag_production_url) { "https://transaction.pagador.com.br" }
  let(:merchant_id) { "um id qualquer" }

  before do
    @connection = mock(:merchant_id => merchant_id)
    Braspag::Connection.stub(:instance => @connection)
  end

  describe ".generate" do
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

  describe ".normalize_params" do
    it "should convert amount to BigDecimal" do
      result = Braspag::Eft.normalize_params({ :amount => "100.2" })
      result.should be_kind_of Hash

      result[:amount].should be_kind_of BigDecimal
    end

    it "should transform installments to Integer" do
      result = Braspag::Eft.normalize_params({ :installments => "12" })
      result.should be_kind_of Hash

      result[:installments].should be_kind_of Integer
      result[:installments].should == 12
    end

    it "should assign 1 to installments if installments is not present" do
      result = Braspag::Eft.normalize_params({})
      result.should be_kind_of Hash

      result[:installments].should == 1
    end

    it "should transform has_interest into String" do
      result = Braspag::Eft.normalize_params({ :has_interest => true })
      result.should be_kind_of Hash

      result[:has_interest].should == "1"

      result = Braspag::Eft.normalize_params({ :has_interest => false })
      result.should be_kind_of Hash

      result[:has_interest].should == "0"
    end
  end

  describe ".check_params" do
    let(:params) do
      {
        :order_id => "111",
        :amount => 100.0,
        :payment_method => :bradesco
      }
    end

    [:order_id, :amount, :payment_method].each do |param|
      it "should raise an error when #{param} is not present" do
        expect {
          params[param] = nil
          Braspag::Eft.check_params(params)
        }.to raise_error Braspag::IncompleteParams
      end
    end

    it "should raise an error when order_id is not valid" do
      Braspag::Eft.should_receive(:valid_order_id?)
                   .with(params[:order_id])
                   .and_return(false)

      expect {
        Braspag::Eft.check_params(params)
      }.to raise_error Braspag::InvalidOrderId
    end

    it "should raise an error when customer_name is present and is greater than 255 chars" do
      expect {
        params[:customer_name] = "b" * 256
        Braspag::Eft.check_params(params)
      }.to raise_error Braspag::InvalidCustomerName
    end

    it "should raise an error when customer_id is present and is greater than 18 chars" do
      expect {
        params[:customer_id] = "1" * 19
        Braspag::Eft.check_params(params)
      }.to raise_error Braspag::InvalidCustomerId
    end

    it "should raise an error when customer_id is present and is less than 11 chars" do
      expect {
        params[:customer_id] = "1" * 10
        Braspag::Eft.check_params(params)
      }.to raise_error Braspag::InvalidCustomerId
    end

    it "should raise an error when installments is present and is greater than 99" do
      expect {
        params[:installments] = 100
        Braspag::Eft.check_params(params)
      }.to raise_error Braspag::InvalidInstallments
    end

    it "should raise an error when installments is present and is less than 99" do
      expect {
        params[:installments] = 0
        Braspag::Eft.check_params(params)
      }.to raise_error Braspag::InvalidInstallments

      expect {
        params[:installments] = 1
        Braspag::Eft.check_params(params)
      }.to_not raise_error Braspag::InvalidInstallments
    end

    it "should raise an error when has_interest is present and is not a boolean" do
      expect {
        params[:has_interest] = "string"
        Braspag::Eft.check_params(params)
      }.to raise_error Braspag::InvalidHasInterest

      expect {
        params[:has_interest] = true
        Braspag::Eft.check_params(params)
      }.to_not raise_error Braspag::InvalidHasInterest

      expect {
        params[:has_interest] = false
        Braspag::Eft.check_params(params)
      }.to_not raise_error Braspag::InvalidHasInterest
    end
  end

  describe ".action_url" do
    it "should return the correct eft creation url when connection environment is homologation" do
      @connection.stub(:braspag_url => braspag_homologation_url)
      Braspag::Eft.action_url.should == "#{braspag_homologation_url}/pagador/passthru.asp"
    end

    it "should return the correct eft creation url when connection environment is production" do
      @connection.stub(:braspag_url => braspag_production_url)
      Braspag::Eft.action_url.should == "#{braspag_production_url}/pagador/passthru.asp"
    end
  end
end
