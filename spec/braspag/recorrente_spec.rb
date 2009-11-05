require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Recorrente do
  before do
    @merchant_id = "{84BE7E7F-698A-6C74-F820-AE359C2A07C2}"
    @connection = Braspag::Connection.new(@merchant_id, :test)
    @recorrente = Braspag::Recorrente.new(@connection)
    response = "<?xml version='1.0' encoding='utf-8'?><soap:Envelope xmlns:soap='http://www.w3.org/2003/05/soap-envelope' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xmlns:xsd='http://www.w3.org/2001/XMLSchema'><soap:Body><CreateCreditCardOrderResponse xmlns='https://www.pagador.com.br/webservice/recorrente'><CreateCreditCardOrderResult><code>1</code><description>teste</description></CreateCreditCardOrderResult></CreateCreditCardOrderResponse></soap:Body></soap:Envelope>"
    mock_response @recorrente, response
  end

  it "deve enviar dados para o webservice de cartao de credito" do
    expected = <<STRING
<?xml version='1.0' ?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Header />
  <env:Body>
    <tns:CreateCreditCardOrder xmlns:tns="https://www.pagador.com.br/webservice/recorrente">
      <tns:merchantId>#{@merchant_id}</tns:merchantId>
      <tns:orderId>123</tns:orderId>
      <tns:startDate>12/11/2009</tns:startDate>
      <tns:endDate>12/12/2009</tns:endDate>
      <tns:recurrenceInterval>1</tns:recurrenceInterval>
      <tns:amount>123,45</tns:amount>
      <tns:paymentMethod>18</tns:paymentMethod>
      <tns:holder>Teste</tns:holder>
      <tns:cardNumber>2222</tns:cardNumber>
      <tns:expirationDate>12/11</tns:expirationDate>
      <tns:securityCode>123</tns:securityCode>
      <tns:numberInstallments>1</tns:numberInstallments>
      <tns:paymentType>0</tns:paymentType>
    </tns:CreateCreditCardOrder>
  </env:Body>
</env:Envelope>
STRING
    response_should_contain(expected)
    @recorrente.create_creditcard_order(:orderId => "123", :startDate => "12/11/2009", :endDate => "12/12/2009", :recurrenceInterval => "1", :amount => "123,45", :paymentMethod => "18", :holder => "Teste", :cardNumber => "2222", :expirationDate => "12/11", :securityCode => "123", :numberInstallments => "1", :paymentType => "0" )
  end

  it "deve devolver dados em um mapa" do
    map = { "code" =>"1", "description" => "teste"}
    @recorrente.create_creditcard_order(:orderId => "123", :startDate => "12/11/2009", :endDate => "12/12/2009", :recurrenceInterval => "1", :amount => "123,45", :paymentMethod => "18", :holder => "Teste", :cardNumber => "2222", :expirationDate => "12/11", :securityCode => "123", :numberInstallments => "1", :paymentType => "0" ).should == map
  end
end
