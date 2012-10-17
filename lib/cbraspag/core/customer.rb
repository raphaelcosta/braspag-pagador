module Braspag
  class Customer
    include ::ActiveAttr::Model

    attr_accessor :name, :document, :email
    
    [:purchase, :generate, :authorize, :archive, :recurrency ].each do |check_on|
      validates :name, :length => {:minimum => 1, :maximum => 100, :on => check_on }
      validates :email, :length => {:minimum => 1, :maximum => 255, :on => check_on, :allow_blank => true}
      validates :document, :length => {:minimum => 11, :maximum => 18, :on => check_on, :allow_blank => true}
    end
  end
end