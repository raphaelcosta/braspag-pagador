module Braspag
  module Crypto
    class Webservice
      def initialize(connection)
        @connection = connection
      end
      
      def encrypt(map)
        
        request = HTTPI::Request.new uri
        
        fields = "\n"
        map.each do |key, value|
          fields.concat("        <tns:string>#{key}=#{value}</tns:string>\n")
        end
        
        
        request.body = <<-STRING
<?xml version="1.0" encoding="utf-8"?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Header />
  <env:Body>
    <tns:EncryptRequest xmlns:tns="https://www.pagador.com.br/webservice/BraspagGeneralService">
      <tns:merchantId>#{@connection.merchant_id}</tns:merchantId>
      <tns:request>
        #{fields}
      </tns:request>
    </tns:EncryptRequest>
  </env:Body>
</env:Envelope>
  STRING
  
        request.headers["Content-Type"] = "text/xml"
        

        response = HTTPI.post request
        
        "XXXX"
      end

      def decrypt(encripted_text)
         request = HTTPI::Request.new uri

          request.body = <<-STRING
<?xml version="1.0" encoding="utf-8"?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Header />
  <env:Body>
    <tns:DecryptRequest xmlns:tns="https://www.pagador.com.br/webservice/BraspagGeneralService">
      <tns:merchantId>#{@connection.merchant_id}</tns:merchantId>
      <tns:cryptString>#{encripted_text}</tns:cryptString>
    </tns:DecryptRequest>
  </env:Body>
</env:Envelope>
    STRING

          request.headers["Content-Type"] = "text/xml"

          response = HTTPI.post request
          
        convert_request_to_map response
      end

      protected
      def uri
        "#{@connection.base_url}/BraspagGeneralService/BraspagGeneralService.asmx"
      end
      
    end
  end
end