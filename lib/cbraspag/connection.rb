module Braspag
  class Connection
    
    PRODUCTION_URL = "https://transaction.pagador.com.br"
    HOMOLOGATION_URL = "https://homologacao.pagador.com.br"
    PROTECTED_CARD_PRODUCTION_URL = "https://cartaoprotegido.braspag.com.br/Services"
    PROTECTED_CARD_HOMOLOGATION_URL = "https://homologacao.braspag.com.br/services/testenvironment"

    AUTHORIZE_CARD_URI = "/webservices/pagador/Pagador.asmx/Authorize"
    CAPTURE_CARD_URI = "/webservices/pagador/Pagador.asmx/Capture"
    VOID_CARD_URI = "/webservices/pagador/Pagador.asmx/VoidTransaction"


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
    
    def url_for(method_name)
      braspag_url = production? ? PRODUCTION_URL : HOMOLOGATION_URL
      protected_url = production? ? PROTECTED_CARD_PRODUCTION_URL : PROTECTED_CARD_HOMOLOGATION_URL
      
      case method_name
      when :authorize
        braspag_url + AUTHORIZE_CARD_URI
      when :void
        braspag_url + VOID_CARD_URI
      when :capture
        braspag_url + CAPTURE_CARD_URI
      end
    end
  end
end
