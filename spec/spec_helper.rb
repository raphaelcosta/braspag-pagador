require 'rubygems'
require 'bundler'
require 'cbraspag'
Bundler.setup(:default, :test, :development)

require 'pry'

RSpec.configure do |config|
  config.mock_with :rspec
  HTTPI.log = false
end
