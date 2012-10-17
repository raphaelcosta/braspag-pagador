module  Braspag
  class Response
    attr_reader :message, :code
    def success?
      true
    end
  end
end