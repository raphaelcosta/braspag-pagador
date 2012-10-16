module Braspag
  class Connection
    
    PRODUCTION_URL = "https://transaction.pagador.com.br"
    HOMOLOGATION_URL = "https://homologacao.pagador.com.br"
    PROTECTED_CARD_PRODUCTION_URL = "https://cartaoprotegido.braspag.com.br/Services"
    PROTECTED_CARD_HOMOLOGATION_URL = "https://homologacao.braspag.com.br/services/testenvironment"

    attr_reader :merchant_id, :env

    def initialize(merchant_id, env)
      raise InvalidMerchantId unless merchant_id =~ /\{[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}\}/i
      raise InvalidEnvironment unless (env == :homologation || env == :production)
      
      @merchant_id = merchant_id
      @env = env
    end

    def production?
      @env == :production
    end

    def homologation?
      @env == :homologation
    end
  end
end
