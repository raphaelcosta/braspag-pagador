require 'rubygems'
require 'bundler'
Bundler.setup(:default)
require 'httpi'
require 'nokogiri'
require 'json'
require 'cbraspag'

RSpec.configure do |config|
  config.mock_with :rspec
  HTTPI.log = false
end
