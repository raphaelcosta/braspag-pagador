module  Braspag
  class Response
    attr_accessor :message, :code
    def success?
      true
    end
  end
end