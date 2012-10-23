module Braspag
  class Customer
    include ::ActiveAttr::Model

    attr_accessor :name, :document, :email
    
    [:purchase, :generate, :authorize, :archive, :recurrency ].each do |check_on|
      validates :name, :length => {:minimum => 1, :maximum => 100, :on => check_on }
      validates :email, :length => {:minimum => 1, :maximum => 255, :on => check_on, :allow_blank => true}
      validates :document, :length => {:minimum => 11, :maximum => 18, :on => check_on, :allow_blank => true}
    end
    
    def convert_to(method)
      data = {}
      data = self.send("to_#{method}") if self.respond_to?("to_#{method}")
      data
    end
    
    def to_authorize
      {
        :customer_name => self.name.to_s
      }
    end
    
    def to_generate_billet
      {
        :customer_name => self.name.to_s,
        :customer_id   => self.document.to_s,
        :emails        => self.email.to_s
      }
    end
       
    def populate!(method)
      
    end
  end
end