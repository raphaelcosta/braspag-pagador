module Braspag
  module Service
   def initialize(connection)
      @connection = connection
      configure_endpoint
    end

    def on_create_document(doc)
      doc.alias 'tns', base_action_url
    end

    def on_response_document(doc)
      doc.add_namespace 'ns', base_action_url
    end

    private
    def configure_endpoint
      self.class.endpoint :uri => uri,
                          :version => 2
    end


  end
end
