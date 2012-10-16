require 'singleton'
require 'httpi'
require 'nokogiri'
require 'json'
require 'savon'

require "cbraspag/version"
require 'cbraspag/errors'
require 'cbraspag/poster'
require 'cbraspag/connection'
require 'cbraspag/utils'

require 'cbraspag/credit_card'

module Braspag
  def self.logger=(value)
    @logger = value
  end

  def self.logger
    @logger
  end

  def self.proxy_address=(value)
    @proxy_address = value
  end

  def self.proxy_address
    @proxy_address
  end
end
