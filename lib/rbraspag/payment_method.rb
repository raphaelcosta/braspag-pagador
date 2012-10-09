module Braspag
  class PaymentMethod
    PAYMENT_METHODS = {
      # BRASIL
      :amex_2p                  => 18,  # American Express 2 Party
      :cielo_noauth_visa        => 71,  # Cielo webservice captura automática sem autenticação - Visa
      :cielo_preauth_visa       => 73,  # Cielo webservice preauth sem autenticação - Visa
      :cielo_noauth_mastercard  => 120, # Cielo webservice captura automática sem autenticação - Mastercard
      :cielo_preauth_mastercard => 122, # Cielo webservice preauth sem autenticação - Mastercard
      :cielo_noauth_elo         => 126, # Cielo webservice captura automática sem autenticação - ELO
      :cielo_noauth_diners      => 130, # Cielo webservice captura automática sem autenticação - Diners
      :redecard                 => 20,  # Redecard Mastercard/Diners/Visa
      :redecard_preauth         => 42,  # Redecard preauth Mastercard/Diners/Visa
      :cielo_sitef              => 57,  # Cielo SITEF
      :hipercard_sitef          => 62,  # Hipercard SITEF
      :hipercard_moip           => 90,  # Hipercard MOIP
      :oi_paggo                 => 55,  # OiPaggo
      :amex_sitef               => 58,  # Amex SITEF
      :aura_dtef                => 37,  # Aura DTEF
      :redecard_sitef           => 44,  # Redecard SITEF - Mastercard/Diners
      # MÉXICO
      :mex_amex_2p            => 45, # American Express 2 Party
      :mex_banorte_visa       => 50, # Banorte Visa
      :mex_banorte_diners     => 52, # Banorte Diners
      :mex_banorte_mastercard => 53, # Banorte Mastercard
      # COLÔMBIA
      :col_visa   => 63, # Visa
      :col_amex   => 65, # Amex
      :col_diners => 66, # Diners
      # INTERNACIONAL
      :paypal_express => 35, # PayPal Express Checkout
      # HOMOLOGATION
      :braspag => 997
    }

    def self.payment_method_from_id(code)
      self::PAYMENT_METHODS.invert.values_at(code).first
    end

    def self.normalize_params(params)
      if params[:amount] && !params[:amount].is_a?(BigDecimal)
        params[:amount] = BigDecimal.new(params[:amount].to_s)
      end

      params
    end

    def self.check_params(params)
      [:order_id, :amount, :payment_method].each do |param|
        raise IncompleteParams if params[param].nil?
      end

      raise InvalidOrderId unless self.valid_order_id?(params[:order_id])

      if params[:customer_name]
        raise InvalidCustomerName unless (1..255).include?(params[:customer_name].to_s.size)
      end

      if params[:customer_id]
        raise InvalidCustomerId unless (11..18).include?(params[:customer_id].to_s.size)
      end

      unless params[:payment_method].is_a?(Symbol) && self::PAYMENT_METHODS[params[:payment_method]]
        raise InvalidPaymentMethod
      end
    end

    def self.valid_order_id?(order_id)
      (order_id.is_a?(String) || order_id.is_a?(Fixnum)) && (1..50).include?(order_id.to_s.size)
    end
  end
end
