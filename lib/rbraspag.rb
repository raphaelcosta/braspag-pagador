require 'singleton'
require 'httpi'
require 'nokogiri'
require 'json'
require 'savon'

require "rbraspag/version"
require 'rbraspag/connection'
require 'rbraspag/payment_method'
require 'rbraspag/crypto/jar_webservice'
require 'rbraspag/crypto/webservice'
require 'rbraspag/bill'
require 'rbraspag/poster'
require 'rbraspag/credit_card'
require 'rbraspag/eft'
require 'rbraspag/errors'
require 'rbraspag/utils'
require 'rbraspag/order'

module Braspag
  def self.logger=(value)
    @logger = value
  end

  def self.logger
    @logger
  end

  def self.config_file_path=(path)
    @config_path = path
  end

  def self.config_file_path
    @config_path || 'config/braspag.yml'
  end
end
