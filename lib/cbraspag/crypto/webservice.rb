module Braspag
  module Crypto
    class Webservice
      def encrypt(connection, map)
        fields = "\n"
        map.each do |key, value|
          fields.concat("        <tns:string>#{key}=#{value}</tns:string>\n")
        end

        data = <<-STRING
<?xml version="1.0" encoding="utf-8"?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Header />
  <env:Body>
    <tns:EncryptRequest xmlns:tns="https://www.pagador.com.br/webservice/BraspagGeneralService">
      <tns:merchantId>#{connection.merchant_id}</tns:merchantId>
      <tns:request>
        #{fields}
      </tns:request>
    </tns:EncryptRequest>
  </env:Body>
</env:Envelope>
STRING
        response = Braspag::Poster.new(
          connection, 
          connection.url_for(:encrypt)
        ).do_post(
          :encrypt,
          data,
          {"Content-Type" => "text/xml"}
        )

        document = Nokogiri::XML(response.body)

        raise 'UnknownError' if document.children.empty?

        #melhorar este parser cof cof
        response = document.children.children.children.children.children.to_s

        raise 'InvalidMerchantId' if (response == 'Erro BP 011' || response == 'Erro BP 012')
        raise 'InvalidIP' if (response == 'Erro BP 067' || response == 'Erro BP 068')

        response
      end

      def decrypt(connection, encripted_text)

        data = <<-STRING
<?xml version="1.0" encoding="utf-8"?>
<env:Envelope xmlns:env="http://www.w3.org/2003/05/soap-envelope">
  <env:Header />
  <env:Body>
    <tns:DecryptRequest xmlns:tns="https://www.pagador.com.br/webservice/BraspagGeneralService">
      <tns:merchantId>#{connection.merchant_id}</tns:merchantId>
      <tns:cryptString>#{encripted_text}</tns:cryptString>
    </tns:DecryptRequest>
  </env:Body>
</env:Envelope>
STRING
        
        response = Braspag::Poster.new(
          connection, 
          connection.url_for(:decrypt)
        ).do_post(
          :decrypt,
          data,
          {"Content-Type" => "text/xml"}
        )

        document = Nokogiri::XML(response.body)
        raise 'UnknownError' if document.children.empty?

        result_error = document.children.children.children.children.children.first.content.to_s

        raise 'InvalidMerchantId' if (result_error == 'Erro BP 011' || result_error == 'Erro BP 012')
        raise 'InvalidIP' if (result_error == 'Erro BP 067' || result_error == 'Erro BP 068')

        convert_request_to_map document
      end

      protected
      def convert_request_to_map(document)
        map = {}
        document.children.children.children.children.children.each do |n|
          values = n.content.to_s.split("=")
          map[values[0].downcase.to_sym] = values[1] if values.size == 2
        end
        map
      end
    end
  end
end
