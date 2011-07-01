require 'rubygems'
require 'rbraspag'
require 'fakeweb'

RSpec.configure do |config|
  config.mock_with :rspec

  HTTPI.log = false
end