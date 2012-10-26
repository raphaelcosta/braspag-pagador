require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Converter do
  describe ".decimal_to_string" do
    it "should convert decimal to string with comma as decimal separator" do
      Braspag::Converter.decimal_to_string(10).should eq("10,00")
      Braspag::Converter.decimal_to_string(1).should eq("1,00")
      Braspag::Converter.decimal_to_string(0.1).should eq("0,10")
      Braspag::Converter.decimal_to_string(0.01).should eq("0,01")
      Braspag::Converter.decimal_to_string(9.99999).should eq("10,00") # round up
      Braspag::Converter.decimal_to_string(10.9).should eq("10,90")
      Braspag::Converter.decimal_to_string(9.1111).should eq("9,11")
      Braspag::Converter.decimal_to_string("10,00").should eq("10,00")
    end
  end
  
  describe ".string_to_decimal" do
    it "should string with comma as decimal separator to decimal" do
      Braspag::Converter.string_to_decimal("1000,00").should eq(1000.00)
      Braspag::Converter.string_to_decimal("1.000,00").should eq(1000.00)
      Braspag::Converter.string_to_decimal("10,00").should eq(10.00)
      Braspag::Converter.string_to_decimal("1,00").should eq(1.00)
      Braspag::Converter.string_to_decimal("0,10").should eq(0.1)
      Braspag::Converter.string_to_decimal("0,01").should eq(0.01)
      Braspag::Converter.string_to_decimal("9,99").should eq(9.99)
      Braspag::Converter.string_to_decimal("10,9").should eq(10.90)
      Braspag::Converter.string_to_decimal("9,1111").should eq(9.1111)
    end
  end

  describe ".hash_from_xml" do
    let(:document) do
      <<-XML
      <root>
        <foo>blabla</foo>
        <bar>bleble</bar>
        <baz></baz>
      </root>
      XML
    end

    context "basic document and keys" do
      it "should return a Hash" do
        keys = { :foo => nil, :meu_elemento => "bar", :outro_elemento => "baz" }
        expected = { :foo => "blabla", :meu_elemento => "bleble", :outro_elemento => nil }

        Braspag::Converter::hash_from_xml(document, keys).should == expected
      end
      
      it "should return a Hash with invalid key" do
        keys = { :foo => "invalid", :meu_elemento => "bar", :outro_elemento => "baz" }
        expected = { :foo => nil, :meu_elemento => "bleble", :outro_elemento => nil }

        Braspag::Converter::hash_from_xml(document, keys).should == expected
      end
    end

    context "keys with a Proc" do
      it "should return a Hash" do
        proc = Proc.new { "value returned by Proc" }

        keys = { :foo => proc, :meu_elemento => "bar", :outro_elemento => "baz" }
        expected = { :foo => "value returned by Proc", :meu_elemento => "bleble", :outro_elemento => nil }

        Braspag::Converter::hash_from_xml(document, keys).should == expected
      end
    end
  end
  
  describe ".payment_method_name?" do
    it "should return name from number" do
      Braspag::Converter.payment_method_name?(6).should eq(:billet_bradesco)
    end

    it "should return name from string" do
      Braspag::Converter.payment_method_name?("6").should eq(:billet_bradesco)
    end

    it "should return name from string with 0" do
      Braspag::Converter.payment_method_name?("06").should eq(:billet_bradesco)
    end

    it "should return nil when not found" do
      Braspag::Converter.payment_method_name?("AAA").should be(nil)
    end
  end
  
  describe ".status_name?" do
    it "should return name from number" do
      Braspag::Converter.status_name?(1).should eq(:starting)
    end

    it "should return name from string" do
      Braspag::Converter.status_name?("1").should eq(:starting)
    end

    it "should return name from string with 0" do
      Braspag::Converter.status_name?("01").should eq(:starting)
    end

    it "should return nil when not found" do
      Braspag::Converter.status_name?("AAA").should be(nil)
    end
  end
  
  describe "payment_method_type?" do
    it "should response nil when invalid method" do
      Braspag::Converter.payment_method_type?(999).should be(nil)
    end
    
    it "should response billet" do
      Braspag::Converter.payment_method_type?(6).should be(:billet)
    end
    
    it "should response eft" do
      Braspag::Converter.payment_method_type?(16).should be(:eft)
    end
    
    it "should response credit_card" do
      Braspag::Converter.payment_method_type?(997).should be(:credit_card)
    end
  end
end
