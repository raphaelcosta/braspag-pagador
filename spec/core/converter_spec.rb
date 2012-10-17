require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Converter do
  describe ".decimal_to_string" do
    it "should convert decimal to string with comma as decimal separator" do
      Braspag::Converter.decimal_to_string(10).should == "10,00"
      Braspag::Converter.decimal_to_string(1).should == "1,00"
      Braspag::Converter.decimal_to_string(0.1).should == "0,10"
      Braspag::Converter.decimal_to_string(0.01).should == "0,01"
      Braspag::Converter.decimal_to_string(9.99999).should == "10,00" # round up
      Braspag::Converter.decimal_to_string(10.9).should == "10,90"
      Braspag::Converter.decimal_to_string(9.1111).should == "9,11"
    end
  end

  describe ".to_map" do
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

        Braspag::Converter::to_map(document, keys).should == expected
      end
    end

    context "keys with a Proc" do
      it "should return a Hash" do
        proc = Proc.new { "value returned by Proc" }

        keys = { :foo => proc, :meu_elemento => "bar", :outro_elemento => "baz" }
        expected = { :foo => "value returned by Proc", :meu_elemento => "bleble", :outro_elemento => nil }

        Braspag::Converter::to_map(document, keys).should == expected
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
  
end
