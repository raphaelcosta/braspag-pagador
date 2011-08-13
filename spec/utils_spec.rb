#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Utils do
  it '.convert_decimal_to_string' do
    Braspag::Utils.convert_decimal_to_string(10.80).should == "1080"
  end

  pending "convert_to_map"
end
