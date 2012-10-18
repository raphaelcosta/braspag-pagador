require 'spec_helper'
require 'ostruct'

describe Braspag::Poster do
  let(:request) { OpenStruct.new(:url => 'http://foo/bar') }
  let(:response) { mock(:body => 'success') }
  let(:logger) { mock(:info => nil) }
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
  let(:connection_logger) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation, :logger => logger)}
  let(:connection_proxy) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation, :proxy_address => 'http://proxy.com')}

  describe "#do_post" do
    before do
      ::HTTPI::Request.should_receive(:new).with('http://foo/bar').and_return(request)
      ::HTTPI.should_receive(:post).with(request).and_return(response)
    end

    context "without proxy and logger" do
      subject { described_class.new(connection, 'http://foo/bar') }

      it "should not set the proxy if the proxy_address is not set" do
        request.should_not_receive(:proxy=)
        subject.do_post(:foo, {})
      end
      
      it "should not raise an error if logger is not defined" do
        expect {
          subject.do_post(:doe, { :foo => :bar, :egg => :span })
        }.to_not raise_error
      end
      
    end

    context "with logger" do
      subject { described_class.new(connection_logger, 'http://foo/bar') }
      
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
    end

    context "with proxy" do
      subject { described_class.new(connection_proxy, 'http://foo/bar') }
      
      it "should set the proxy if the proxy_address is set" do
        request.should_receive(:proxy=).with('http://proxy.com')
        subject.do_post(:foo, {})
      end
    end
  end
end
