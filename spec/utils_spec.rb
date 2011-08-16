#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Utils do
  it '.convert_decimal_to_string' do
    Braspag::Utils.convert_decimal_to_string(10.80).should == "10,80"
  end

  it '.convert_decimal_to_string' do
    Braspag::Utils.convert_decimal_to_string(10.00).should == "10,00"
  end
  
  it '.convert_decimal_to_string' do
    Braspag::Utils.convert_decimal_to_string(1).should == "1,00"
  end
  
  it '.convert_decimal_to_string' do
    Braspag::Utils.convert_decimal_to_string(1.00).should == "1,00"
  end

  it '.convert_decimal_to_string' do
    Braspag::Utils.convert_decimal_to_string(0.90).should == "0,90"
  end
  
  pending "convert_to_map"
end
