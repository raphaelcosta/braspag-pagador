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
    
    def convert_to(method)
      self.send("to_#{method}")
    end
    
    def to_generate_billet
      {
        :number => self.id.to_s,
        :instructions => self.instructions.to_s,
        :expiration_date => self.due_date_on.strftime("%d/%m/%y")
      }
    end
    
    def populate!(method, response)
      self.send("populate_#{method}!", response)
    end
    
    def populate_generate_billet!(response)
      self.url = response[:url]
    end
  end
end
