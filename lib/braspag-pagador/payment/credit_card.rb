module BraspagPagador
  class Connection
    def purchase(order, credit_card)
      resp = self.authorize(order, credit_card)
      resp = self.capture(order) if resp.success?
      resp
    end

    def authorize(order, credit_card)
      response = self.post(:authorize, order, credit_card)

      status = (response[:status] == "0" || response[:status] == "1")

      ActiveMerchant::Billing::Response.new(status,
                   response[:message],
                   response,
                   :test => homologation?,
                   :authorization => response[:number])
    end

    def capture(order)
      response = self.post(:capture, order)

      status = (response[:status] == "0")

      ActiveMerchant::Billing::Response.new(status,
                   response[:message],
                   response,
                   :test => homologation?,
                   :authorization => response[:number])
    end

    def void(order, partial=nil)
      response = self.post(:void, order)

      status = (response[:status] == "0")

      ActiveMerchant::Billing::Response.new(status,
                   response[:message],
                   response,
                   :test => homologation?)
    end
  end

  class CreditCard
    include ::ActiveAttr::Model

    attr_accessor :holder_name, :number, :month, :year, :verification_value, :alias, :id
    attr_accessor :checking_number, :avs, :autorization_number, :transaction_number
    attr_accessor :avs_response, :issuing, :authenticated_number

    class ExpiratorValidator < ActiveModel::EachValidator
      def validate_each(record, attribute, value)
        begin
          year = record.year.try(:to_i)
          year = "20#{year}".to_i if year && year.to_s.size == 2

          month = record.month.try(:to_i)

          Date.new(year, month) if year && month
        rescue ArgumentError
          record.errors.add attribute, "invalid date"
        end
      end
    end


    [:purchase, :authorize, :save_credit_card].each do |check_on|
      validates :holder_name, :length => {:minimum => 1, :maximum => 100, :on => check_on}

      validates :number, :presence => { :on => check_on }

      validates :month, :presence => { :on => check_on }
      validates :month, :expirator => { :on => check_on }
      validates :year, :presence => { :on => check_on }
      validates :year, :expirator => { :on => check_on }
    end

    [:purchase, :authorize].each do |check_on|
      # validates :verification_value, :length => {:minimum => 1, :maximum => 4, :on => check_on}
    end

    [:get_recurrency, :recurrency].each do |check_on|
      validates :id, :length => {:is => 36, :on => check_on}
    end

    def self.to_save_credit_card(connection,credit_card,customer,request_id)
      {
        'saveCreditCardRequestWS'  => {
          'MerchantKey'    => connection.merchant_id,
          'CustomerName'   => customer.name.to_s,
          'CardHolder'     => credit_card.holder_name.to_s,
          'CardNumber'     => credit_card.number.to_s,
          'CardExpiration' => "#{format('%02d', credit_card.month)}/#{credit_card.year}",
          'RequestId'      => request_id
        }
      }
    end

    def self.from_save_credit_card(connection,credit_card, customer, request_id, params)
      params = params.body
      params[:save_credit_card_response][:save_credit_card_result]
    end

    def self.to_get_credit_card(connection,just_click_key)
      {
        'getCreditCardRequestWS'  => {
          'MerchantKey'    => connection.merchant_id,
          'JustClickKey'   => just_click_key
        }
      }
    end

    def self.from_get_credit_card(connection,just_click_key,params)
      params = params.body
      params[:get_credit_card_response][:get_credit_card_result]
    end

    def self.to_authorize(connection, order, credit_card)
      year_normalize = credit_card.year.to_s[-2, 2]
      {
        "merchantId"     => connection.merchant_id,
        "holder"         => credit_card.holder_name.to_s,
        "cardNumber"     => credit_card.number.to_s,
        "expiration"     => "#{credit_card.month}/#{year_normalize}",
        "securityCode"   => credit_card.verification_value.to_s,
        "customerName"   => order.customer.name.to_s,
        "orderId"        => order.id.to_s,
        "amount"         => BraspagPagador::Converter::decimal_to_string(order.amount),
        "paymentMethod"  => order.payment_method,
        "numberPayments" => order.installments,
        "typePayment"    => order.installments_type
      }
    end

    def self.from_authorize(connection, order, credit_card, params)
      response = BraspagPagador::Converter::hash_from_xml(params.body, {
              :amount         => nil,
              :number         => "authorisationNumber",
              :message        => nil,
              :return_code    => 'returnCode',
              :status         => nil,
              :transaction_id => "transactionId"
      })

      order.gateway_authorization = response[:number]
      order.gateway_id = response[:transaction_id]
      order.gateway_return_code = response[:return_code]
      order.gateway_status = response[:status]
      order.gateway_message = response[:message]
      order.gateway_amount = BraspagPagador::Converter::string_to_decimal(response[:amount])

      response
    end

    def self.to_capture(connection, order)
      {
        "merchantId"  => connection.merchant_id,
        "orderId"     => order.id.to_s
      }
    end

    def self.from_capture(connection, order, params)
      response = BraspagPagador::Converter::hash_from_xml(params.body, {
              :amount => nil,
              :message => 'message',
              :return_code => 'returnCode',
              :status => 'status',
              :transaction_id => "transactionId"
      })

      #TODO: CHECK IF IS NECESSARY
      # order.gateway_capture_id = response[:transaction_id]
      order.gateway_capture_return_code = response[:return_code]
      order.gateway_capture_status = response[:status]
      order.gateway_capture_message = response[:message]
      order.gateway_capture_amount = BraspagPagador::Converter::string_to_decimal(response[:amount])

      response
    end

    def self.to_void(connection, order)
      {
        "merchantId" => connection.merchant_id,
        "order"      => order.id.to_s
      }
    end

    def self.from_void(connection, order, params)
      response = BraspagPagador::Converter::hash_from_xml(params.body, {
              :order_id => "orderId",
              :amount => nil,
              :message => 'message',
              :return_code => 'returnCode',
              :status => 'status',
              :transaction_id => "transactionId"
      })

      #TODO: CHECK IF IS NECESSARY
      # order.gateway_void_id = response[:transaction_id]
      order.gateway_void_return_code = response[:return_code]
      order.gateway_void_status = response[:status]
      order.gateway_void_message = response[:message]
      order.gateway_void_amount = BraspagPagador::Converter::string_to_decimal(response[:amount])

      response
    end
  end
end
