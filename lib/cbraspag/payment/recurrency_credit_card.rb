module Braspag
  class Connection
    PROTECTED_CARD_MAPPING = {
      :request_id => "RequestId",
      :merchant_id => "MerchantKey",
      :customer_name => "CustomerName",
      :holder => "CardHolder",
      :card_number => "CardNumber",
      :expiration => "CardExpiration"
    }

    JUST_CLICK_MAPPING = {
      :request_id => "RequestId",
      :merchant_id => "MerchantKey",
      :customer_name => "CustomerName",
      :order_id => "OrderId",
      :amount => "Amount",
      :payment_method => "PaymentMethod",
      :number_installments => "NumberInstallments",
      :payment_type => "PaymentType",
      :just_click_key => "JustClickKey",
      :security_code => "SecurityCode"
    }


    # saves credit card in Braspag PCI Compliant
    def archive(credit_card, customer, request_id)

      self.check_protected_card_params(params)

      data = { 'saveCreditCardRequestWS' => {} }

      PROTECTED_CARD_MAPPING.each do |k, v|
        data['saveCreditCardRequestWS'][v] = params[k] || ""
      end


     client = Savon::Client.new(self.save_protected_card_url)
     response = client.request(:web, :save_credit_card) do
       soap.body = data
     end

      response.to_hash[:save_credit_card_response][:save_credit_card_result]

    end

    # request the credit card info in Braspag PCI Compliant
    def get_recurrency(credit_card)

      raise InvalidJustClickKey unless valid_just_click_key?(just_click_key)

      data = { 'getCreditCardRequestWS' => {:loja => connection.merchant_id, :justClickKey => just_click_key} }

      request = ::HTTPI::Request.new(self.get_protected_card_url)
      request.body = { 'getCreditCardRequestWS' => {:loja => connection.merchant_id, :justClickKey => just_click_key} }

      response = ::HTTPI.post(request)

      response = Utils::convert_to_map(response.body, {
          :holder => "CardHolder",
          :card_number => "CardNumber",
          :expiration => "CardExpiration",
          :masked_card_number => "MaskedCardNumber"
        })

      raise UnknownError if response[:card_number].nil?
      response
    end

    def recurrency(order, credit_card, request_id)

      self.check_just_click_shop_params(params)

      order_id = params[:order_id]
      raise InvalidOrderId unless self.valid_order_id?(order_id)

      data = { 'justClickShopRequestWS' => {} }

      JUST_CLICK_MAPPING.each do |k, v|
        case k
        when :payment_method
          data['justClickShopRequestWS'][v] = Braspag::Connection.instance.homologation? ? PAYMENT_METHODS[:braspag] : PAYMENT_METHODS[params[:payment_method]]
        else
          data['justClickShopRequestWS'][v] = params[k] || ""
        end
      end

      client = Savon::Client.new(self.just_click_shop_url)
      response = client.request(:web, :just_click_shop) do
        soap.body = data
      end

      response.to_hash[:just_click_shop_response][:just_click_shop_result]

    end

    
  end
end
