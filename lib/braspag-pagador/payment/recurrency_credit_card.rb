module BraspagPagador
  class Connection
    def save_credit_card(credit_card, customer, request_id)
      response = self.soap_request(:save_credit_card, credit_card, customer, request_id)
      status = response[:success]

      ActiveMerchant::Billing::Response.new(status,nil,response,:test => homologation?)
    end

    # request the credit card info in Braspag PCI Compliant
    def get_recurrency(credit_card)

    end

    def recurrency(order, credit_card, request_id)

    end
  end
end
