require 'spec_helper'
require 'ostruct'

describe Braspag::Poster do
  let(:request) { OpenStruct.new(:url => 'http://foo/bar') }
  let(:response) { mock(:body => 'success') }
  let(:logger) { mock(:info => nil) }
  subject { described_class.new('http://foo/bar') }
  before { Braspag.logger = logger }

  describe "#do_post" do
    before do
      ::HTTPI::Request.should_receive(:new).with('http://foo/bar').and_return(request)
      ::HTTPI.should_receive(:post).with(request).and_return(response)
    end

    it "should log the request info" do
      logger.should_receive(:info).with('[Braspag] #doe: http://foo/bar, data: {:foo=>:bar, :egg=>:span}')
      subject.do_post(:doe, { :foo => :bar, :egg => :span })
    end

    it "should log the request info removing the credit card sensitive info" do
      logger.should_receive(:info).with('[Braspag] #doe: http://foo/bar, data: {"cardNumber"=>"************", "securityCode"=>"***"}')
      subject.do_post(:doe, { 'cardNumber' => '123', 'securityCode' => '456' })
    end

    it "should log response info" do
      logger.should_receive(:info).with('[Braspag] #doe: http://foo/bar, data: {:foo=>:bar, :egg=>:span}')
      subject.do_post(:doe, { :foo => :bar, :egg => :span })
    end

    it "should not raise an error if logger is not defined" do
      Braspag.logger = nil
      expect {
        subject.do_post(:doe, { :foo => :bar, :egg => :span })
      }.to_not raise_error
    end

    it "should not set the proxy if the proxy_address is not set" do
      request.should_not_receive(:proxy=)
      subject.do_post(:foo, {})
    end

    context "using a proxy" do
      before { Braspag.proxy_address = 'http://proxy.com' }

      it "should set the proxy if the proxy_address is set" do
        request.should_receive(:proxy=).with('http://proxy.com')
        subject.do_post(:foo, {})
      end
    end
  end
end
