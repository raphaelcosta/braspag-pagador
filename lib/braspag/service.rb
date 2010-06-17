module Braspag
  module Service
   def initialize(connection)
      @connection = connection
      self.class.endpoint :uri => uri, :version => 2
    end

    def on_create_document(doc)
      doc.alias 'tns', base_action_url
    end

    def on_response_document(doc)
      doc.add_namespace 'ns', base_action_url
    end
  end
end
