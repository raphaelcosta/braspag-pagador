require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Braspag::Utils do
  describe ".convert_decimal_to_string" do
    it "should convert decimal to string with comma as decimal separator" do
      Braspag::Utils.convert_decimal_to_string(10).should == "10,00"
      Braspag::Utils.convert_decimal_to_string(1).should == "1,00"
      Braspag::Utils.convert_decimal_to_string(0.1).should == "0,10"
      Braspag::Utils.convert_decimal_to_string(0.01).should == "0,01"
      Braspag::Utils.convert_decimal_to_string(9.99999).should == "10,00" # round up
      Braspag::Utils.convert_decimal_to_string(10.9).should == "10,90"
      Braspag::Utils.convert_decimal_to_string(9.1111).should == "9,11"
    end
  end

  describe ".convert_to_map" do
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

        Braspag::Utils::convert_to_map(document, keys).should == expected
      end
    end

    context "keys with a Proc" do
      it "should return a Hash" do
        proc = Proc.new { "value returned by Proc" }

        keys = { :foo => proc, :meu_elemento => "bar", :outro_elemento => "baz" }
        expected = { :foo => "value returned by Proc", :meu_elemento => "bleble", :outro_elemento => nil }

        Braspag::Utils::convert_to_map(document, keys).should == expected
      end
    end
  end
end
