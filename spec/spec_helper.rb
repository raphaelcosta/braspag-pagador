require 'rubygems'
require 'rbraspag'
require 'fakeweb'

ENV["RACK_ENV"] ||= "test"

RSpec.configure do |config|
  config.mock_with :rspec
  config.after(:each) do
    FakeWeb.clean_registry
  end

  HTTPI.log = false
  FakeWeb.allow_net_connect = false
end
