module Braspag
  module Crypto
    class Webservice
      def self.encrypt(map)
        connection = Braspag::Connection.instance
        raise Braspag::IncompleteParams if map.nil?
        raise Braspag::IncompleteParams unless map.is_a?(Hash)

        request = ::HTTPI::Request.new self.uri

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
      <tns:merchantId>#{connection.merchant_id}</tns:merchantId>
      <tns:request>
        #{fields}
      </tns:request>
    </tns:EncryptRequest>
  </env:Body>
</env:Envelope>
STRING

        request.headers["Content-Type"] = "text/xml"

        response = ::HTTPI.post request

        document = Nokogiri::XML(response.body)

        raise Braspag::UnknownError if document.children.empty?

        #melhorar este parser cof cof
        response = document.children.children.children.children.children.to_s

        raise Braspag::InvalidMerchantId if (response == 'Erro BP 011' || response == 'Erro BP 012')
        raise Braspag::InvalidIP if (response == 'Erro BP 067' || response == 'Erro BP 068')

        response
      end

      def self.decrypt(encripted_text)
        connection = Braspag::Connection.instance

        raise Braspag::IncompleteParams if encripted_text.nil?
        raise Braspag::IncompleteParams unless encripted_text.is_a?(String)

        request = ::HTTPI::Request.new self.uri

        request.body = <<-STRING
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

        request.headers["Content-Type"] = "text/xml"

        response = ::HTTPI.post request

        document = Nokogiri::XML(response.body)
        raise Braspag::UnknownError if document.children.empty?

        result_error = document.children.children.children.children.children.first.content.to_s

        raise Braspag::InvalidMerchantId if (result_error == 'Erro BP 011' || result_error == 'Erro BP 012')
        raise Braspag::InvalidIP if (result_error == 'Erro BP 067' || result_error == 'Erro BP 068')

        self.convert_request_to_map document
      end

      protected
      def self.convert_request_to_map(document)
        map = {}
        document.children.children.children.children.children.each do |n|
          values = n.content.to_s.split("=")
          map[values[0].downcase.to_sym] = values[1]
        end
        map
      end
    end
  end
end
