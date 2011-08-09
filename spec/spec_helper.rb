require 'rubygems'
require 'rbraspag'
require 'fakeweb'

ENV["RACK_ENV"] ||= "test"

RSpec.configure do |config|
  config.mock_with :rspec

  HTTPI.log = false
end