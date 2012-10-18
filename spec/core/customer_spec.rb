require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Customer do
  [:purchase, :generate, :authorize, :archive, :recurrency ].each do |context_type|
    context "on #{context_type}" do
      it "should validate minimum 1 length of name" do
        subject.name = ''
        subject.valid?(context_type)
        subject.errors.messages[:name].should include("is too short (minimum is 1 characters)")
      end

      it "should validate maximum 100 length of name" do
        subject.name = '*' * 110
        subject.valid?(context_type)
        subject.errors.messages[:name].should include("is too long (maximum is 100 characters)")
      end

      it "should allow blank for email" do
        subject.email = ''
        subject.valid?(context_type)
        subject.errors.messages[:email].should be(nil)
      end

      it "should validate maximum 255 length of email" do
        subject.email = '*' * 260
        subject.valid?(context_type)
        subject.errors.messages[:email].should include("is too long (maximum is 255 characters)")
      end

      it "should allow blank for document" do
        subject.document = ''
        subject.valid?(context_type)
        subject.errors.messages[:document].should be(nil)
      end

      it "should validate minimum 11 length of document" do
        subject.document = 'XXX'
        subject.valid?(context_type)
        subject.errors.messages[:document].should include("is too short (minimum is 11 characters)")
      end

      it "should validate maximum 18 length of document" do
        subject.document = '*' * 20
        subject.valid?(context_type)
        subject.errors.messages[:document].should include("is too long (maximum is 18 characters)")
      end
    end
  end
end