require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Braspag" do
  describe "braspag" do
    before do
      @proxy = Braspag.new('https://homologacao.pagador.com.br/BraspagGeneralService/BraspagGeneralService.asmx?WSDL')
    end

    describe "calling EncryptRequest" do
      it "should return true for a valid ISBN" do
        @proxy.EncryptRequest(:merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}', :request => ['NOME=ricardo','VALOR=100']).should == 'flM0k1VtgwE9PziabNZSGJDAicmROP0zfqCVq/j+r1B0oteNjecSXa7XXdm3rFBV'
      end
    end

    describe "calling DecryptRequest" do
      it "should return true for a valid ISBN" do
        @proxy.DecryptRequest(:merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}', :crypt => 'flM0k1VtgwE9PziabNZSGJDAicmROP0zfqCVq/j+r1B0oteNjecSXa7XXdm3rFBV').to_set.should == ['NOME=ricardo', 'VALOR=100'].to_set
      end
    end
  end
end
