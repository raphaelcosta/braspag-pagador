module Braspag
  class Layout
    attr_accessor :identifier, :min_length, :max_length, :allow_blank, :format, :value

    def initialize(identifier, min_length, max_length, params = {})
      params = params.merge(:allow_blank => true, :format => '', :default => '')
      self.identifier = identifier
      self.min_length = min_length
      self.max_length = max_length
      self.allow_blank = params[:allow_blank]
      self.format = params[:format].is_a?(Regexp) ? params[:format] : nil
      self.value = params[:default]
    end

    def valid?
  #    result = false
  #    if allow_blank && value.
  #      result = (!value.match(format).nil?) if format
   #   result = true if
       true
    end
  end
end
