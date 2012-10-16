module Braspag
  module Crypto
    class JarWebservice
      def self.encrypt(map)
        crypto_key = Braspag::Connection.instance.crypto_key
        raise Braspag::IncompleteParams if map.nil?
        raise Braspag::IncompleteParams unless map.is_a?(Hash)

        request = ::HTTPI::Request.new encrypt_uri

        data = {:key => crypto_key, :fields => map}

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

      def self.decrypt(encrypted, fields)
        crypto_key = Braspag::Connection.instance.crypto_key
        raise Braspag::InvalidEncryptedKey if encrypted.nil?
        raise Braspag::InvalidEncryptedKey unless encrypted.is_a?(String)

        raise Braspag::IncompleteParams if fields.nil?
        raise Braspag::IncompleteParams unless fields.is_a?(Array)


        request = ::HTTPI::Request.new decrypt_uri
        request.body = {
        	"key" => crypto_key,
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
      def self.encrypt_uri
        connection_uri = Braspag::Connection.instance.crypto_url
        "#{connection_uri}/v1/encrypt.json"
      end

      def self.decrypt_uri
        connection_uri = Braspag::Connection.instance.crypto_url
        "#{connection_uri}/v1/decrypt.json"
      end

    end
  end
end