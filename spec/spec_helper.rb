$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'rspec'
require 'handsoap'
require 'braspag'

class ApplicationController
end

class HttpDriver
  def self.respond_with(content)
    @body = content
  end

  def self.send_http_request(request)
    response_for @body
  end

  def self.body
    @body
  end
end

class Handsoap::Service
  def http_driver_instance
    HttpDriver
  end
end

def response_for(body)
  headers = { "content-type" => ["application/soap+xml; charset=utf-8"] }
  Handsoap::Http::Response.new 200, headers, body, [HttpDriver]
end

def respond_with(content)
  HttpDriver.respond_with content
end

def request_should_contain(expected)
  HttpDriver.should_receive(:send_http_request) do |request|
    request.body.lines.to_a.each do |line|
      expected.should include(line)
    end
    response_for expected
  end
end
