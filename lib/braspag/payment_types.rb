module Braspag
  TIPOS_PAGAMENTOS = {
    :internacional => {
      :paypal                             => 35  # [Internacional] PayPal
    },
    :brasil => {
      :boleto_bradesco                    =>  6, # [Brasil] Boleto Bradesco
      :boleto_caixa                       =>  7, # [Brasil] Boleto Caixa
      :boleto_hsbc                        =>  8, # [Brasil] Boleto HSBC
      :boleto_banco_brasil                =>  9, # [Brasil] Boleto Banco do Brasil
      :boleto_real                        => 10, # [Brasil] Boleto Real ABN AMRO
      :boleto_citibank                    => 13, # [Brasil] Boleto Citibank
      :boleto_itau                        => 14, # [Brasil] Boleto Itaú
      :boleto_unibanco                    => 26, # [Brasil] Boleto Unibanco
      :boleto_bank_boston                 => 33, # [Brasil] Boleto Bank Boston
      :boleto_brb                         => 38, # [Brasil] Boleto BRB
      :boleto_safra                       => 40, # [Brasil] Boleto Safra

      :debito_bradesco                    => 11, # [Brasil] Débito Bradesco (SPS)
      :debito_itau                        => 12, # [Brasil] Débito Itaú (Shopline)
      :debito_banrisul                    => 30, # [Brasil] Débito Banrisul
      :debito_unibanco                    => 31, # [Brasil] Débito Unibanco

      :visa_credito                       =>  1, # [Brasil] Visa Crédito - VBV
      :visa_debito                        =>  2, # [Brasil] Visa Electron
      :mastercard                         =>  3, # [Brasil] Mastercard - Komerci
      :diners                             =>  4, # [Brasil] Diners - Komerci

      :american_express_3_party           =>  5, # [Brasil] American Express – 3 Party
      :american_express_2_party           => 18, # [Brasil] Amex 2 party
      :american_express_vpos              => 21, # [Brasil] Amex - VPOS
      :comercio_eletronico_banco_brasil   => 15, # [Brasil] Comercio Eletrônico – Banco do Brasil

      :visa_tef                           => 22, # [Brasil] Visa – TEF
      :mastercard_tef                     => 23, # [Brasil] Mastercard – TEF
      :diners_tef                         => 24, # [Brasil] Diners – TEF
      :american_express_tef               => 25, # [Brasil] Amex – TEF
      :hipercard_tef                      => 29, # [Brasil] Hipercard – TEF

      :financiamento_bbpag                => 32, # [Brasil] Financiamento BBPag
      :financiamento_bradesco             => 34, # [Brasil] Financiamento Bradesco
      :financiamento_netcredit_cetelem    => 54, # [Brasil]Financiamento NetCredit/Cetelem

      :real_pague                         => 16, # [Brasil] RealPague
      :redecard_webservice                => 20, # [Brasil] Webservice Redecard
      :real_flv                           => 28, # [Brasil] Real FLV
      :visa_moset                         => 36, # [Brasil] Visa MOSET
      :aura                               => 37, # [Brasil] Aura
      :credito_consignado                 => 39, # [Brasil] Crédito Consignado
      :visa_moset3                        => 41, # [Brasil] Visa Moset3
      :mastercard_webservice_pre_auth     => 42, # [Brasil] Mastercard Webservice PreAuth
      :redecard_sitef_mastercard_diners   => 44, # [Brasil] Redecard SiTef (Mastercard/Diners)
      :oi_paggo                           => 55  # [Brasil] OiPaggo
    },
    :mexico => {
      :visa                               => 50, # [México] Visa
      :american_express                   => 51, # [México] Amex
      :diners                             => 52, # [México] Diners
      :mastercard                         => 53  # [México] Mastercard
    },
    :argentina => {
      :visanet                            => 70, # [Argentina] Visanet
      :argencard_mastercard               => 71, # [Argentina] Argencard Mastercard
      :argencard_jcb                      => 72, # [Argentina] Argencard JCB
      :american_express                   => 73  # [Argentina] Amex
    },
    :chile => {
      :visa                               => 80, # [Chile] Visa
      :mastercard                         => 81  # [Chile] Mastercard
    },
    :usa => {
      :american_express_chase_paymentech  => 100, # [USA] ChasePaymentech Amex
      :visa__chase_paymentech             => 101, # [USA] ChasePaymentech Visa
      :mastercard_chase_paymentech        => 102, # [USA] ChasePaymentech Mastercard
      :diners_chase_paymentech            => 103  # [USA] ChasePaymentech Diners
    }
  }
end
