require "bigdecimal"

module Braspag
  class Connection
    def generate_billet(order, billet)
      response = self.post(:generate_billet, order, billet)
      status = (response[:status] == "0")

      ActiveMerchant::Billing::Response.new(status,
                   response[:message],
                   response,
                   :test => homologation?,
                   :authorization => response[:number])
    end
  end
  
  class Billet
    include ::ActiveAttr::Model
    
    class DueDateValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        # unless value.class.in? [Date, Time]
        unless (
          value.kind_of?(Time) || value.kind_of?(Date)
        )
          record.errors.add attribute, "invalid date"
        end
      end
    end
    
    attr_accessor :id, :instructions, :due_date_on, :url

    validates :id, :length => {:minimum => 1, :maximum => 255, :on => :generate, :allow_blank => true }
    validates :instructions, :length => {:minimum => 1, :maximum => 512, :on => :generate, :allow_blank => true }
    validates :due_date_on, :presence => { :on => :generate }
    validates :due_date_on, :due_date => { :on => :generate }
    
    def self.to_generate_billet(connection, order, billet)
      {
        "merchantId"       => connection.merchant_id,
        "boletoNumber"     => billet.id.to_s,
        "instructions"     => billet.instructions.to_s,
        "expirationDate"   => billet.due_date_on.strftime("%d/%m/%y"),
        "customerName"     => order.customer.name.to_s,
        "customerIdNumber" => order.customer.document.to_s,
        "emails"           => order.customer.email.to_s,
        "orderId"          => order.id.to_s,
        "amount"           => Braspag::Converter::decimal_to_string(order.amount),
        "paymentMethod"    => order.payment_method
      }
    end
    
    def self.from_generate_billet(connection, order, billet, params)
      response = Braspag::Converter::hash_from_xml(params.body, {
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
      
      order.gateway_return_code = response[:return_code]
      order.gateway_status = response[:status]
      order.gateway_amount = BigDecimal.new(response[:amount].to_s) if response[:amount]
      billet.url = response[:url]
      
      response
    end
  end
end
