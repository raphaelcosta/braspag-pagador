require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Recorrente do
  before do
    @merchant_id = "{234234-234234-234234}"
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
    </tns:CreateCreditCardOrder>
  </env:Body>
</env:Envelope>
STRING
    response_should_contain(expected)
    @recorrente.create_creditcard_order(:orderId => "123", :startDate => "12/11/2009", :endDate => "12/12/2009")
  end

  it "deve devolver dados em um mapa" do
    map = { "code" =>"1", "description" => "teste"}
    @recorrente.create_creditcard_order(:orderId => "123", :startDate => "12/11/2009", :endDate => "12/12/2009").should == map
  end
end
