module Braspag
  module Crypto
    class Webservice
      def encrypt(connection, map)
        data = ERB.new(File.read(Braspag::PATH + '/braspag/templates/crypto/encrypt.xml.erb'))

        response = Braspag::Poster.new(
          connection, 
          connection.url_for(:encrypt)
        ).do_post(
          :encrypt,
          data.result(binding),
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
        data = ERB.new(File.read(Braspag::PATH + '/braspag/templates/crypto/decrypt.xml.erb'))
        
        response = Braspag::Poster.new(
          connection, 
          connection.url_for(:decrypt)
        ).do_post(
          :decrypt,
          data.result(binding),
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
