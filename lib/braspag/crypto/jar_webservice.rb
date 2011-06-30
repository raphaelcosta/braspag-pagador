module Braspag
  module Crypto
    class JarWebservice
      
      def initialize(crypto_key, connection_uri)
        @crypto_key = crypto_key
        @connection_uri = connection_uri
      end
      
      def encrypt(map)
        
        request = HTTPI::Request.new encrypt_uri
        
        data = {:key => @crypto_key, :fields => map}
                            
        request.headers["Content-Type"] = "application/json"
        
        request.body = data.to_json
        
        response = HTTPI.post request

        response = JSON.parse(response.body)
        
        response["encrypt"]
      end

      def decrypt(encrypted, fields)
        request = HTTPI::Request.new decrypt_uri
        request.body = {
        	"key" => @crypto_key,
        	"encrypted" => encrypted,
        	"fields" => fields
        }.to_json

        request.headers["Content-Type"] = "application/json"

        response = HTTPI.post request

        response = JSON.parse(response.body)
        
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