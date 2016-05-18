# braspag-pagador [![Build Status](https://travis-ci.org/raphaelcosta/braspag-pagador.png?branch=master)](https://travis-ci.org/raphaelcosta/braspag-pagador)

braspag-pagador gem to use Braspag gateway

  - Based on gem cbraspag from Codeminer42 and other forks
  - Support most operations in gateway
  - Compatible with Active Merchant response object
  - Support multiple connections easy
  - Support just click key ( Save creditcard)

Many people contributed on this project to generate this release, thanks to all these people:

@gonow
@renatoelias
@drec18
@ricardoalmeida
@lenonmarcel
@tinogomes
@madsoncardo
@lucabastos
@cassiomarques
@codeminer42
@vinibaggio

## RUN INTEGRATION TEST

    BRASPAG_MERCHANT_ID={YOUR_MECHANT_ID} be rspec -t integration

## Usage CreditCard

  This simple example demonstrates how a purchase can be made using a person's
  credit card details.

  	require 'rubygems'
  	require 'braspag-pagador'

  	gateway = BraspagPagador::Connection.new(
  	  :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
  	  :environment => :homologation
  	)

  	# The card verification value is also known as CVV2, CVC2, or CID
  	credit_card = BraspagPagador::CreditCard.new(
  	  :holder_name        => 'Bob Bobsen',
  	  :number             => '4242424242424242',
  	  :month              => '8',
  	  :year               => '2012',
  	  :verification_value => '123'
  	)

  	customer = BraspagPagador::Customer.new(
  	  :name => 'Bob Dela Bobsen'
  	)

  	order = BraspagPagador::Order.new(
  	  :payment_method    => BraspagPagador::PAYMENT_METHOD[:redecard],
  	  :id                => 11,
  	  :amount            => 10.00, # $10.00 (accepts all amounts as Integer values in cents)
  	  :customer          => customer,
  	  :installments      => 1,
  	  :installments_type => BraspagPagador::INTEREST[:no]
  	)

  	# Validating the card automatically detects the card type
  	if credit_card.valid?(:purchase) && customer.valid?(:purchase) && order.valid?(:purchase)
  	  # Capture $10 from the credit card
  	  response = gateway.purchase(order, credit_card)

  	  if response.success?
  	    puts "Successfully charged $#{sprintf("%.2f", order.amount / 100)} to the credit card #{order.gateway_id}"
  	  else
  	    raise StandardError, response.message
  	  end
  	end

## Usage Billet

  This simple example demonstrates how create billet to a person.

  	require 'rubygems'
  	require 'braspag-pagador'

  	gateway = BraspagPagador::Connection.new(
  	  :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
  	  :environment => :homologation
  	)

  	billet = BraspagPagador::Billet.new(
  	  :id           => '123456', # (optional if configured in gateway)
  	  :instructions => 'does not accepted after due date', # (optional)
  	  :due_date_on  => Date.parse('2012-01-01')
  	)

  	customer = BraspagPagador::Customer.new(
  	  :document     => '21473696240', # (OPTIONAL)
  	  :name   => 'Bob Dela Bobsen',
  	  :email  => 'bob@mailinator.com' # send email to consumer (OPTIONAL)
  	)

  	order = BraspagPagador::Order.new(
  	  :payment_method  => BraspagPagador::PAYMENT_METHOD[:billet_bradesco],
  	  :id              => 11,
  	  :amount          => 10.00, # $10.00 (accepts all amounts as Integer values in cents)
  	  :customer        => customer
  	)

  	# Validating the card automatically detects the card type
  	if billet.valid?(:generate) && customer.valid?(:generate) && order.valid?(:generate)
  	  response = gateway.generate_billet(order, billet)

  	  if response.success?
  	    puts "Successfully created billet, open in:#{billet.url}"
  	  else
  	    raise StandardError, response.message
  	  end
  	end

## Usage EFT (Eletronic Founds Transfer)

  This simple example demonstrates how create eft to a person.

  	require 'rubygems'
  	require 'braspag-pagador'

  	gateway = BraspagPagador::Connection.new(
  	  :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
  	  :environment => :homologation
  	)

  	#USING Braspag Webservice
  	eft = BraspagPagador::EFT.new(
  	  :crypto => BraspagPagador::Crypto::Webservice.new
  	)

  	#Without Crypto
  	eft = BraspagPagador::EFT.new(
  	  :crypto => BraspagPagador::Crypto::NoCrypto.new
  	)

  	customer = BraspagPagador::Customer.new(
  	  :name   => 'Bob Dela Bobsen'
  	)

  	order = BraspagPagador::Order.new(
  	  :payment_method  => BraspagPagador::PAYMENT_METHOD[:eft_itau],
  	  :id              => 1234,
  	  :amount          => '1000', # $10.00 (accepts all amounts as Integer values in cents)
  	  :customer        => customer
  	)

  	# Validating the card automatically detects the card type
  	if eft.valid?(:generate) && customer.valid?(:generate) && order.valid?(:generate)
  	  response = gateway.generate_eft(order, eft)

  	  if response.success?
  	    puts "Successfully created eft, continue in:#{eft.code}"
  	  else
  	    raise StandardError, response.message
  	  end
  	end

## CREDITCARD AUTHORIZE

  This simple example demonstrates how a authorize can be made using a person's
  credit card details.

  	require 'rubygems'
  	require 'braspag-pagador'

  	gateway = BraspagPagador::Connection.new(
  	  :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
  	  :environment => :homologation
  	)

  	# The card verification value is also known as CVV2, CVC2, or CID
  	credit_card = BraspagPagador::CreditCard.new(
  	  :holder_name        => 'Bob Bobsen',
  	  :number             => '4242424242424242',
  	  :month              => '8',
  	  :year               => '2012',
  	  :verification_value => '123'
  	)

  	customer = BraspagPagador::Customer.new(
  	  :name => 'Bob Dela Bobsen'
  	)

  	order = BraspagPagador::Order.new(
  	  :payment_method    => BraspagPagador::PAYMENT_METHOD[:redecard],
  	  :id                => 11,
  	  :amount            => '1000', # $10.00 (accepts all amounts as Integer values in cents)
  	  :customer          => customer,
  	  :installments      => 1,
  	  :installments_type => BraspagPagador::INTEREST[:no]
  	)

  	# Validating the card automatically detects the card type
  	if credit_card.valid?(:authorize) && customer.valid?(:authorize) && order.valid?(:authorize)
  	  # Authorize $10 from the credit card
  	  response = gateway.authorize(order, credit_card)

  	  if response.success?
  	    puts "Successfully authorized $#{sprintf("%.2f", order.amount / 100)} to the credit card #{order.gateway_id}"
  	  else
  	    raise StandardError, response.message
  	  end
  	end

## CREDITCARD CAPTURE

  This simple example demonstrates how a capture can be made, after authorize.

  	require 'rubygems'
  	require 'braspag-pagador'

  	gateway = BraspagPagador::Connection.new(
  	  :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
  	  :environment => :homologation
  	)

  	order = BraspagPagador::Order.new(
  	  :id => 11
  	)

  	# Capture $10 from the credit card
  	response = gateway.capture(order)

  	if response.success?
  	  puts "Successfully charged #{order.id}"
  	else
  	  raise StandardError, response.message
  	end

## CREDITCARD VOID

  This simple example demonstrates how a void transaction can be made.

  	require 'rubygems'
  	require 'braspag-pagador'

  	gateway = BraspagPagador::Connection.new(
  	  :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
  	  :environment => :homologation
  	)

  	order = BraspagPagador::Order.new(
  	  :id => 11
  	)

  	response = gateway.void(order)

  	if response.success?
  	  puts "Successfully charged #{order.id}"
  	else
  	  raise StandardError, response.message
  	end

### Partial Void

  If need specify partial amount


  	response = gateway.void(order, '500')



## ORDER INFO

  Sometimes your need get status in braspag

  	> order = Order.new(:id => "1234")
  	> response = gateway.get(order)

  	> if response.success?
  	>   puts order.authorization
  	>   "148519"

  	>   puts order.payment_method_name
  	>   "Boleto Santander"

  	>   puts order.payment_method
  	>   "06"

  	>   puts BraspagPagador::Converter.payment_method_name?(order.payment_method)
  	>   :billet_bradesco

  	>   puts order.installments
  	>   1

  	>   puts order.status
  	>   4

  	>   puts BraspagPagador::Converter.status_name?(order.status)
  	>   :cancelled

  	>   puts order.amount
  	>   500

  	>   # Kind a datetime
  	>   puts order.gateway_cancelled_at
  	>   2012-10-13 03:30:15 -0300

  	>   # Kind a datetime
  	>   puts order.gateway_paid_at
  	>   2012-10-12 13:42:30 -0300

  	>   # Kind a datetime
  	>   puts order.gateway_created_at
  	>   2012-10-11 17:44:23 -0300

  	>   puts order.transaction_id
  	>   "342818"

  	>   puts order.gateway_id
  	>   "02ff02e2-f1ce-4c2b-a874-a20bb98fb97e<"

  	> else
  	>  puts response.code
  	>  "XPTO"

  	>  puts response.message
  	>  puts "ERROR XPTO"
  	> end



### CREDITCARD DETAILS

  If order is a credit card, extras fields returning:

  	> order = Order.new(:id => "1234")
  	> response = gateway.get(order)

  	> puts order.credit_card.checking_number
  	> "342818"

  	> puts order.credit_card.avs
  	> false

  	> puts order.credit_card.autorization_number
  	> "148519"

  	> puts order.credit_card.card_number
  	> "345678*****0007"

  	> puts order.credit_card.transaction_number
  	> "101014343175"

  	> puts order.credit_card.avs_response
  	> "XPX RESPONSE"

  	> puts order.credit_card.issuing
  	> "XPX"

  	> puts order.credit_card.authenticated_number
  	> "112934"


### BILL DETAILS

  If order is a billet, extras fields returning:

  	> order = Order.new(:id => "1234")
  	> response = gateway.get(order)

  	> puts order.customer.name
  	> "Teste"

  	> puts order.billet.id
  	> "00070475"

  	> puts order.billet.code
  	> "35690.00361 03962.030007 00000.704759 6 54930000010000"

  	> # Kind a date
  	> puts order.billet.created_at
  	> 2012-10-11

  	> # Kind a date
  	> puts order.billet.due_date_on
  	> 2012-10-13

  	> puts order.billet.receiver
  	> "Codeminer42"

  	> puts order.billet.bank
  	> "356-5"

  	> puts order.billet.agency
  	> "0003"

  	> puts order.billet.account
  	> "6039620"

  	> puts order.billet.wallet
  	> "57"

  	> puts order.billet.amount
  	> 100.00

  	> puts order.billet.amount_paid
  	> 100.00

  	> # Kind a date
  	> puts order.billet.paid_at
  	> 2012-10-12

## CREDITCARD RECURRING SAVE

  Save credit card in Braspag PCI Compliant

  	require 'rubygems'
  	require 'braspag-pagador'

  	gateway = BraspagPagador::Connection.new(
  	  :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
  	  :environment => :homologation
  	)

  	# The card verification value is also known as CVV2, CVC2, or CID
  	credit_card = BraspagPagador::CreditCard.new(
  	  :holder_name        => 'Bob Bobsen',
  	  :number             => '4242424242424242',
  	  :month              => '8',
  	  :year               => '2012',
  	  :alias              => 'Card Visa' #(OPTIONAL)
  	)

  	customer = BraspagPagador::Customer.new(
  	  :name => 'Bob Dela Bobsen'
  	  :document => '21473696240' #(OPTIONAL)
  	)

  	# Validating the card automatically detects the card type
  	if credit_card.valid?(:archive) && customer.valid?(:archive)
  	  response = gateway.save_credit_card(credit_card, customer, "00000000-0000-0000-0000-000000000044")

  	  if response.success?
  	    puts "Successfully saved credit_card! The just key #{credit_card.id}"
  	  else
  	    raise StandardError, response.message
  	  end
  	end

## CREDITCARD RECURRING GET

  Request the credit card info in Braspag PCI Compliant

  	require 'rubygems'
  	require 'braspag-pagador'

  	gateway = BraspagPagador::Connection.new(
  	  :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
  	  :environment => :homologation
  	)


    just_click_key = '231231288as-asdassad23423asd-324234'
    credit_card = gateway.get_credit_card(just_click_key)

  	  if response.success?
  	    puts "Successfully get credit!"
  	    puts "Holder: #{credit_card.holder_name}"
  	    puts "Number: #{credit_card.number}"
  	    puts "Month: #{credit_card.month}"
  	    puts "Year: #{credit_card.year}"
  	  else
  	    raise StandardError, response.message
  	  end
  	end

## JUST CLICK KEY GET

  Request the just_click_key info in Braspag PCI Compliant

    require 'rubygems'
    require 'braspag-pagador'

    gateway = BraspagPagador::Connection.new(
      :merchant_id => '{84BE7E7F-698A-6C74-F820-AE359C2A07C2}',
      :environment => :homologation
    )


    request_id = '231231288as-asdassad23423asd-324234'
    just_click_key = gateway.get_just_click_key(request_id)

      if response.success?
        puts "Successfully get just click key #{just_click_key}!"
      else
        raise StandardError, response.message
      end
    end

# License

(The MIT License)

Copyright (c) 2013 - Raphael Costa raphael(at)raphaelcosta.net
Copyright (c) 2013 - Codeminer42 contato(at)codeminer42.com

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

