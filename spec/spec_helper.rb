$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'braspag'
require 'spec'

class ApplicationController
end

def headers
  headers = {"content-type" => ["application/soap+xml; charset=utf-8"] }
end
def mock_response(clazz, response)
  document = clazz.parse_soap_response_document(response)
  clazz.on_response_document document
  @response = Handsoap::Http::Response.new(200, headers, response, nil)
  @driver = mock(Object)
  clazz.stub!(:http_driver_instance).and_return(@driver)
  @driver.stub!(:send_http_request).with(anything).and_return(@response)
end

def response_should_contain(expected)
  @driver.should_receive(:send_http_request) do |document|
    document.body.lines.to_a.each do |line|
      expected.include?(line).should be_true
    end
  end
end
