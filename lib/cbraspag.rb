require "rubygems"
require "bundler/setup"
require 'active_attr'
require 'httpi'
require 'json'
require 'nokogiri'
require 'savon'
require 'bigdecimal'
require 'active_merchant'

require "cbraspag/version"
require 'cbraspag/core/converter'
require 'cbraspag/core/connection'
require 'cbraspag/core/poster'
require 'cbraspag/core/customer'
require 'cbraspag/core/order'

require 'cbraspag/crypto/no_crypto'
require 'cbraspag/crypto/jar_webservice'
require 'cbraspag/crypto/webservice'

require 'cbraspag/payment/billet'
require 'cbraspag/payment/credit_card'
require 'cbraspag/payment/eft'


module Braspag
  
  INTEREST = {
    :no            => 0,
    :merchant      => 1,
    :customer      => 2,
    :merchant_iata => 3,
    :customer_iata => 4,
    :no_iata       => 5
  }
  
  STATUS_PAYMENT = {
    :starting  => 1,
    :close     => 2,
    :paid      => 3,
    :cancelled => 4
  }
  
  PAYMENT_METHOD = {
    #BILLET
    :billet_bradesco          => 6,  #Boleto Bradesco
    :billet_cef               => 7,   #Boleto Caixa Economica Federal
    :billet_hsbc              => 8,   #Boleto HSBC
    :billet_banco_do_brasil   => 9,   #Boleto Banco do Brasil
    :billet_santader          => 10,  #Boleto Banco Santader
    :billet_citibank          => 13,  #Boleto Citibank
    :billet_itau              => 14,  #Boleto Itau
    :billet_unibanco          => 26,  #Boleto Unibanco
    #EFT                      
    :eft_bradesco             => 11,  #EFT Bradesco
    :eft_itau                 => 12,  #EFT Itau Shopline
    :eft_banco_do_brasil      => 15,  #EFT Banco do Brasil
    :eft_banco_real           => 16,  #EFT Banco Real
    :eft_banrisul             => 30,  #EFT Banrisul
    :eft_unibanco             => 31,  #EFT Unibanco
    #CARDS - BRASIL
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
    #CARDS - MEXICO
    :mex_amex_2p            => 45, # American Express 2 Party
    :mex_banorte_visa       => 50, # Banorte Visa
    :mex_banorte_diners     => 52, # Banorte Diners
    :mex_banorte_mastercard => 53, # Banorte Mastercard
    #CARDS - COLOMBIA
    :col_visa   => 63, # Visa
    :col_amex   => 65, # Amex
    :col_diners => 66, # Diners
    # INTERNACIONAL
    :paypal_express => 35, # PayPal Express Checkout
    # HOMOLOGATION
    :braspag => 997
  }
end
