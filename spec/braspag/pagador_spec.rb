require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Pagador do
  before do
    @merchant_id = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
    @connection = Braspag::Connection.new(@merchant_id, :test)
    @pagador = Braspag::Pagador.new(@connection)
    response = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><EncryptRequestResponse xmlns='https://www.pagador.com.br/webservice/BraspagGeneralService'><EncryptRequestResult>#{@key}</EncryptRequestResult></EncryptRequestResponse></soap:Body></soap:Envelope>"
    mock_response @pagador, response
  end

  it "deve realizar webservice de autorizacao" do
    expected = <<STRING
<?xml version='1.0' ?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Header />
  <env:Body>
    <tns:Authorize xmlns:tns="https://www.pagador.com.br/webservice/pagador">
      <tns:merchantId>#{@merchant_id}</tns:merchantId>
      <tns:orderId>123</tns:orderId>
      <tns:customerName>Joao</tns:customerName>
      <tns:amount>123,00</tns:amount>
      <tns:paymentMethod>20</tns:paymentMethod>
      <tns:holder>Teste</tns:holder>
      <tns:cardNumber>123456789</tns:cardNumber>
      <tns:expiration>12/11</tns:expiration>
      <tns:securityCode>123</tns:securityCode>
      <tns:numberPayments>1</tns:numberPayments>
      <tns:typePayment>0</tns:typePayment>
    </tns:Authorize>
  </env:Body>
</env:Envelope>
STRING
    response_should_contain(expected)
    result = @pagador.autorizar(:orderId => "123", :customerName => "Joao", :amount => "123,00", :paymentMethod => "20", :holder => "Teste", :cardNumber => "123456789", :expiration => "12/11", :securityCode => "123", :numberPayments => "1", :typePayment => "0" )
    result.should == ""
  end
end
