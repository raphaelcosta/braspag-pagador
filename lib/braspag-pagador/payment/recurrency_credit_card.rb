module BraspagPagador
  class Connection
    def save_credit_card(credit_card, customer, request_id)
      response = self.soap_request(:save_credit_card, credit_card, customer, request_id)
      status = response[:success]

      ActiveMerchant::Billing::Response.new(status,nil,response,:test => homologation?)
    end

    def get_credit_card(just_click_key)
      response = self.soap_request(:get_credit_card, just_click_key)
      status = response[:success]

      if status
        expire_month, expire_year = response[:card_expiration].split('/')
        response = BraspagPagador::CreditCard.new(
           holder_name:        response[:card_holder],
           number:             response[:card_number],
           month:              expire_month,
           year:               expire_year
         )
      else
        ActiveMerchant::Billing::Response.new(status,nil,response,:test => homologation?)
      end
    end

    def authorize_saved_credit_card(order,just_click_key)
      credit_card = get_credit_card(just_click_key)

      response = self.post(:authorize, order, credit_card)

      status = (response[:status] == "0" || response[:status] == "1")

      ActiveMerchant::Billing::Response.new(status,
                                            response[:message],
                                            response,
                                            :test => homologation?,
                                            :authorization => response[:number])
    end

  end
end
