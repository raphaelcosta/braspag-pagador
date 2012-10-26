require 'rubygems'
require 'bundler'

Bundler.setup(:default, :test, :development)

require 'simplecov'
SimpleCov.start do
  add_group "Core", "lib/cbraspag/core"
  add_group "Crypto", "lib/cbraspag/crypto"
  add_group "Payment", "lib/cbraspag/payment"
  add_group "ActiveMerchant", "lib/cbraspag/active_mechant"
  add_group "Spec", "spec"
end

require 'pry'
require 'cbraspag'

HTTPI.log = false

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run_excluding :integration => true, :billet_integration => true
  config.run_all_when_everything_filtered = true
end
