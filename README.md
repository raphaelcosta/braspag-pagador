# rBraspag

rbraspag gem to use Braspag gateway

* This gem need RACK_ENV environment variable to identify the environment

# How to install

## for Rails 3 app

### Add on your Gemfile

	gem "rbraspag"

### Create a config/braspag.yml file

	$ rails generate braspag:install

### Set RACK_ENV (our suggest)

	# add last line in config/environment.rb
    # ...
    # ENV["RACK_ENV"] ||= ENV["RAILS_ENV"]

### Edit config/braspag.yml with your Braspag merchant_id

# Examples

## to create a Bill (Boleto/Bloqueto for brazilian guys)
    @bill = Braspag::Bill.generate({
      :order_id => 1,
      :amount => 3,
      :payment_method => 10
    })

# License

(The MIT License)

Copyright (c) 2010

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

