module Braspag
  class Connection
    def archive(credit_card, customer, request_id)
      year_normalize = credit_card.year.to_s[-2, 2]
      
      template = ERB.new 'save_credit'
      puts template.result(binding)
    end
    # request the credit card info in Braspag PCI Compliant
    def get_recurrency(credit_card)

    end

    def recurrency(order, credit_card, request_id)
      
    end
  end
end
