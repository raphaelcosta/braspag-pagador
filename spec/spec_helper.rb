require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test, :development)

require 'simplecov'
SimpleCov.start do
  add_group "Core", "lib/braspag/core"
  add_group "Crypto", "lib/braspag/crypto"
  add_group "Payment", "lib/braspag/payment"
  add_group "ActiveMerchant", "lib/braspag/active_mechant"
  add_group "Spec", "spec"
end

require 'pry'
require 'braspag'

HTTPI.log = false

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run_excluding :integration => true, :billet_integration => true
  config.run_all_when_everything_filtered = true
end
