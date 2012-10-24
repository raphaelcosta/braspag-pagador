module Braspag
  class Converter
    def self.decimal_to_string(value)
      ("%.2f" % value.to_f).gsub('.', ',')
    end
    
    def self.string_to_decimal(value)
      BigDecimal.new(value.to_s.gsub(".",""))
    end

    def self.to_map(document, map = {})
      document = Nokogiri::XML(document)

      map.each do |key, value|
        if value.is_a?(String) || value.nil?
          value = key if value.nil?

          new_value = document.search(value).first

          if new_value.nil?
            map[key] = nil
          else
            new_value = new_value.content.to_s
            map[key] = new_value unless new_value == ""
            map[key] = nil if new_value == ""
          end

        elsif value.is_a?(Proc)
          map[key] = value.call(document)
        end
      end

      map
    end
    
    def self.payment_method_name?(code)
      Braspag::PAYMENT_METHOD.key(code.to_s.to_i)
    end
    
    def self.status_name?(code)
      Braspag::STATUS_PAYMENT.key(code.to_s.to_i)
    end
    
    def self.to_hash(format, params)
      data = {}
      format.each do |k, v|
        case k
        when :amount
          data[v] = self.decimal_to_string(params[:amount])
        else
          data[v] = params[k] || ""
        end
      end
      data
    end
    
    def self.to(method, data)
      self.send("to_#{method}", data)
    end
    
    def self.to_authorize(params)
      self.to_hash({
        :merchant_id => "merchantId",
        :order_id => "orderId",
        :customer_name => "customerName",
        :amount => "amount",
        :payment_method => "paymentMethod",
        :holder => "holder",
        :card_number => "cardNumber",
        :expiration => "expiration",
        :security_code => "securityCode",
        :number_payments => "numberPayments",
        :type => "typePayment",
      }, params)
    end
    
    def self.to_capture(params)
      self.to_hash({
        :merchant_id => "merchantId",
        :order_id => "orderId"
      }, params)
    end
    
    def self.to_void(params)
      self.to_hash({
        :merchant_id => "merchantId",
        :order_id => "order"
      }, params)
    end
    
    def self.to_generate_billet(params)
      self.to_hash({
        :merchant_id => "merchantId",
        :order_id => "orderId",
        :customer_name => "customerName",
        :customer_id => "customerIdNumber",
        :amount => "amount",
        :payment_method => "paymentMethod",
        :number => "boletoNumber",
        :instructions => "instructions",
        :expiration_date => "expirationDate",
        :emails => "emails"
      }, params)
    end
    
    def self.from(method, data)
      self.send("from_#{method}", data)
    end
    
    def self.from_authorize(data)
      to_map(data, {
        :amount => nil,
        :number => "authorisationNumber",
        :message => 'message',
        :return_code => 'returnCode',
        :status => 'status',
        :transaction_id => "transactionId"
      })
    end
    
    def self.from_capture(data)
      to_map(data, {
        :amount => nil,
        :message => 'message',
        :return_code => 'returnCode',
        :status => 'status',
        :transaction_id => "transactionId"
      })
    end
    
    def self.from_void(data)
      to_map(data, {
        :order_id => "orderId",
        :amount => nil,
        :message => 'message',
        :return_code => 'returnCode',
        :status => 'status',
        :transaction_id => "transactionId"
      })
    end
    
    def self.from_generate_billet(data)
      to_map(data, {
        :url => nil,
        :amount => nil,
        :number => "boletoNumber",
        :expiration_date => Proc.new { |document|
          begin
            Date.parse(document.search("expirationDate").first.to_s)
          rescue
            nil
          end
        },
        :return_code => "returnCode",
        :status => nil,
        :message => nil
      })
    end
  end
end
