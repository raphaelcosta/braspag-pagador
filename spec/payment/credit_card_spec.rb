require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  let(:merchant_id) { "{12345678-1234-1234-1234-123456789000}" }
  let(:connection) { Braspag::Connection.new(:merchant_id => merchant_id, :environment => :homologation)}
  
  context ".purchase" do
    it "should return authorize when authroize response failed" do
      auth = mock(:success? => false)
      connection.stub(:authorize).and_return(auth)
      connection.purchase(mock, mock).should eq(auth)
    end
    
    it "should return capture when authorize response success" do
      cap = mock(:success? => true)
      connection.stub(:authorize).and_return(mock(:success? => true))
      connection.stub(:capture).and_return(cap)
      connection.purchase(mock, mock).should eq(cap)
    end
  end
  
  context ".authorize" do
    it "should return response" do
      authorize = {
        :status  => "2",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(authorize)
      
      response = connection.authorize(mock, mock)
      
      response.success?.should eq(false)
      response.message.should eq(authorize[:message])
      response.authorization.should eq(authorize[:number])
      response.params.should eq({"status"=>"2", "message"=>"BLA", "number"=>"12345"})
      response.test.should eq(true)
    end

    it "should return success when status is zero" do
      authorize = {
        :status  => "0",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(authorize)
      
      response = connection.authorize(mock, mock)
      
      response.success?.should eq(true)
    end
    
    it "should return success when status is one" do
      authorize = {
        :status  => "1",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(authorize)
      
      response = connection.authorize(mock, mock)
      
      response.success?.should eq(true)
    end
  end
  
  context ".capture" do
    it "should return response" do
      capture = {
        :status  => "1",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(capture)
      
      response = connection.capture(mock)
      
      response.success?.should eq(false)
      response.message.should eq(capture[:message])
      response.authorization.should eq(capture[:number])
      response.params.should eq({"status"=>"1", "message"=>"BLA", "number"=>"12345"})
      response.test.should eq(true)
    end

    it "should return success when status is zero" do
      capture = {
        :status  => "0",
        :message => "BLA",
        :number  => "12345"
      }
      
      connection.should_receive(:post).and_return(capture)
      
      response = connection.capture(mock)
      
      response.success?.should eq(true)
    end
  end
  
  context ".void" do
    it "should return response" do
      void = {
        :status  => "1",
        :message => "BLA"
      }
      
      connection.should_receive(:post).and_return(void)
      
      response = connection.void(mock)
      
      response.success?.should eq(false)
      response.message.should eq(void[:message])
      response.params.should eq({"status"=>"1", "message"=>"BLA"})
      response.test.should eq(true)
    end

    it "should return success when status is zero" do
      void = {
        :status  => "0",
        :message => "BLA"
      }
      
      connection.should_receive(:post).and_return(void)
      
      response = connection.void(mock)
      
      response.success?.should eq(true)
    end
  end
end

describe Braspag::CreditCard do
  
  [:purchase, :authorize, :archive].each do |context_type|
    context "on #{context_type}" do
      it "should validate minimum 1 length of holder_name" do
        subject.holder_name = ''
        subject.valid?(context_type)
        subject.errors.messages[:holder_name].should include("is too short (minimum is 1 characters)")
      end

      it "should validate maximum 100 length of holder_name" do
        subject.holder_name = '*' * 110
        subject.valid?(context_type)
        subject.errors.messages[:holder_name].should include("is too long (maximum is 100 characters)")
      end

      it "should not allow blank for number" do
        subject.number = ''
        subject.valid?(context_type)
        subject.errors.messages[:number].should include("can't be blank")
      end

      it "should not allow blank for month" do
        subject.month = ''
        subject.valid?(context_type)
        subject.errors.messages[:month].should include("can't be blank")
      end

      it "should not allow blank for year" do
        subject.year = ''
        subject.valid?(context_type)
        subject.errors.messages[:year].should include("can't be blank")
      end
      
      it "should not allow invalid date for month & year" do
        subject.month = "14"
        subject.year = "2012"
        subject.valid?(context_type)
        subject.errors.messages[:month].should include("invalid date")
        subject.errors.messages[:year].should include("invalid date")
      end

      it "should allow valid date for month & year" do
        subject.month = "09"
        subject.year = "12"
        subject.valid?(context_type)
        subject.errors.messages[:month].should be(nil)
        subject.errors.messages[:year].should be(nil)
      end

      it "should allow valid date for month & year" do
        subject.month = 12
        subject.year = 2014
        subject.valid?(context_type)
        subject.errors.messages[:month].should be(nil)
        subject.errors.messages[:year].should be(nil)
      end
    end
  end
  
  [:purchase, :authorize, :recurrency].each do |context_type|
    context "on #{context_type}" do
      it "should validate minimum 1 length of verification_value" do
        subject.verification_value = ''
        subject.valid?(context_type)
        subject.errors.messages[:verification_value].should include("is too short (minimum is 1 characters)")
      end

      it "should validate maximum 4 length of verification_value" do
        subject.verification_value = '*' * 5
        subject.valid?(context_type)
        subject.errors.messages[:verification_value].should include("is too long (maximum is 4 characters)")
      end
    end
  end
  
  [:get_recurrency, :recurrency].each do |context_type|
    context "on #{context_type}" do
      it "should validate length of id" do
        subject.id = '*' * 37
        subject.valid?(context_type)
        subject.errors.messages[:id].should include("is the wrong length (should be 36 characters)")
      end
    end
  end
  
end
