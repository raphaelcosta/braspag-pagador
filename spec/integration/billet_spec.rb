# encoding: utf-8
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Braspag::Connection do
  it "should generate a billet", :billet_integration => true do
    gateway = Braspag::Connection.new(
      :merchant_id => ENV['BRASPAG_MERCHANT_ID'],
      :environment => :homologation
    )
    
    billet = Braspag::Billet.new(
      :instructions => 'does not accepted after due date', # (optional)
      :due_date_on  => Date.today + 2
    )
    
    customer = Braspag::Customer.new(
      :document     => '21473696240', # (OPTIONAL)
      :name   => 'Bob Dela Bobsen',
      :email  => 'bob@mailinator.com' # send email to consumer (OPTIONAL)
    )
    
    order = Braspag::Order.new(
      :payment_method  => Braspag::PAYMENT_METHOD[:billet_santader],
      :id              => 11,
      :amount          => 10.00, # $10.00 (accepts all amounts as Integer values in cents)
      :customer        => customer
    )
    
    # Validating the card automatically detects the card type
    if billet.valid?(:generate) && customer.valid?(:generate) && order.valid?(:generate)
      response = gateway.generate_billet(order, billet)
      response.success?.should eq(true)
      puts "Successfully created billet, open in:#{billet.url}"
    else
      fail "Invalid Params"
    end
  end
end