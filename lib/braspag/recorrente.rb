module Braspag
  class Recorrente < Handsoap::Service
    BASE_ACTION_URL = "https://www.pagador.com.br/webservice/recorrente"

    def initialize(connection)
      @connection = connection
      configure_endpoint
    end

    def on_create_document(doc)
      doc.alias 'tns', BASE_ACTION_URL
    end

    def on_response_document(doc)
      doc.add_namespace 'ns', BASE_ACTION_URL
    end

    private
    def configure_endpoint
      self.class.endpoint :uri => "#{@connection.base_url}/webservice/recorrente.asmx",
                          :version => 2
    end
  end
end
