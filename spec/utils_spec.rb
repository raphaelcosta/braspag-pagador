#encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Utils do

  describe '#payment_method_from_id' do
    
    it 'Credit card amex' do
      Braspag::Utils.payment_method_from_id('CreditCard', 18).should == :amex_2p
      Braspag::Utils.payment_method_from_id('CreditCard', 18).should be_kind_of Symbol
    end

    it 'Bill of bradesco' do
      Braspag::Utils.payment_method_from_id('Bill', "06").should == :bradesco
      Braspag::Utils.payment_method_from_id('Bill', "06").should be_kind_of Symbol
    end

    it 'Eft of unibanco' do
      Braspag::Utils.payment_method_from_id('Eft', 31).should == :unibanco
      Braspag::Utils.payment_method_from_id('Eft', 31).should be_kind_of Symbol
    end

  end

end
