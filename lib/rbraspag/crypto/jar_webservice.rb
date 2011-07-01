module Braspag
  module Crypto
    class JarWebservice
      
      def initialize(crypto_key, connection_uri)
        @crypto_key = crypto_key
        @connection_uri = connection_uri
      end
      
      def encrypt(map)
        raise Braspag::IncompleteParams if map.nil?
        raise Braspag::IncompleteParams unless map.is_a?(Hash)
        
        request = ::HTTPI::Request.new encrypt_uri
        
        data = {:key => @crypto_key, :fields => map}
                            
        request.headers["Content-Type"] = "application/json"
        
        request.body = data.to_json
        
        response = ::HTTPI.post request
        
        begin
          response = JSON.parse(response.body)
        rescue Exception => e
          raise UnknownError
        end
        
        raise IncompleteParams if (
          response["msg"] == "INVALID FORMAT" || 
          response["msg"] == "INVALID FIELDS" 
        )
        
        raise InvalidEncryptedKey if response["msg"] == "INVALID ENCRYPTED STRING"
        raise InvalidCryptKey if response["msg"] == "INVALID KEY"
        
        response["encrypt"]
      end

      def decrypt(encrypted, fields)
        raise Braspag::InvalidEncryptedKey if encrypted.nil?
        raise Braspag::InvalidEncryptedKey unless encrypted.is_a?(String)
        
        raise Braspag::IncompleteParams if fields.nil?
        raise Braspag::IncompleteParams unless fields.is_a?(Array)
        
        
        request = ::HTTPI::Request.new decrypt_uri
        request.body = {
        	"key" => @crypto_key,
        	"encrypted" => encrypted,
        	"fields" => fields
        }.to_json

        request.headers["Content-Type"] = "application/json"

        response = ::HTTPI.post request

        begin
          response = JSON.parse(response.body)
        rescue Exception => e
          raise UnknownError
        end
        
        raise IncompleteParams if (
          response["msg"] == "INVALID FORMAT" || 
          response["msg"] == "INVALID FIELDS" 
        )
        
        raise InvalidEncryptedKey if response["msg"] == "INVALID ENCRYPTED STRING"

        raise InvalidCryptKey if response["msg"] == "INVALID KEY"
                
        map = {}
        response["fields"].each do |key,value|
          map[key.downcase.to_sym] = value
        end
        map
      end

      protected
      def encrypt_uri
        "#{@connection_uri}/v1/encrypt.json"
      end
      
      def decrypt_uri
        "#{@connection_uri}/v1/decrypt.json"
      end
      
    end
  end
end