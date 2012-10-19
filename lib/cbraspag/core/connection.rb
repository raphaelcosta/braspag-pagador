module Braspag
  class Connection

    class InvalidMerchantId < Exception ; end
    class InvalidEnvironment < Exception ; end
    
    PRODUCTION_URL = "https://transaction.pagador.com.br"
    HOMOLOGATION_URL = "https://homologacao.pagador.com.br"
    PROTECTED_CARD_PRODUCTION_URL = "https://cartaoprotegido.braspag.com.br/Services"
    PROTECTED_CARD_HOMOLOGATION_URL = "https://homologacao.braspag.com.br/services/testenvironment"

    attr_reader :merchant_id, :env, :logger, :proxy_address

    def initialize(params = {})
      merchant_id = params[:merchant_id]
      env = params[:environment]
      raise InvalidMerchantId unless merchant_id =~ /\{[a-z0-9]{8}-([a-z0-9]{4}-){3}[a-z0-9]{12}\}/i
      raise InvalidEnvironment unless (env == :homologation || env == :production)
      
      @merchant_id = merchant_id
      @env = env
      @logger = params[:logger]
      @proxy_address = params[:proxy_address]
    end

    def production?
      @env == :production
    end

    def homologation?
      @env == :homologation
    end
    
    def url_for(method_name)
      braspag_url = production? ? PRODUCTION_URL : HOMOLOGATION_URL
      protected_card_url = production? ? PROTECTED_CARD_PRODUCTION_URL : PROTECTED_CARD_HOMOLOGATION_URL

      braspag_info_url = if production?
        braspag_url + "/webservices/pagador/pedido.asmx"
      else
        braspag_url + "/pagador/webservice/pedido.asmx"
      end
      
      case method_name
      when :authorize
        braspag_url + "/webservices/pagador/Pagador.asmx/Authorize"
      when :void
        braspag_url + "/webservices/pagador/Pagador.asmx/VoidTransaction"
      when :capture
        braspag_url + "/webservices/pagador/Pagador.asmx/Capture"
      when :generate_billet
        braspag_url + "/webservices/pagador/Boleto.asmx/CreateBoleto"
      when :generate_eft
        braspag_url + "/pagador/passthru.asp"
      when :info_billet
        braspag_info_url + "/GetDadosBoleto"
      when :info_card
        braspag_info_url + "/GetDadosCartao"
      when :info
        braspag_info_url + "/GetDadosPedido"
      when :encrypt
        braspag_url + "/BraspagGeneralService/BraspagGeneralService.asmx"
      when :archive_card
        protected_card_url + "/CartaoProtegido.asmx?wsdl"
      when :get_card
        protected_card_url + "/CartaoProtegido.asmx/GetCreditCard"
      when :recurrency
        protected_card_url + "/CartaoProtegido.asmx?wsdl"
      end
    end
    
    def convert_to(method)
      {:merchant_id => self.merchant_id}
    end
    
    def post(method, *args)
      data = convert_to(method)
      args.each do |field|
        data.merge!(field.convert_to(method))
      end

      data = Converter::to(method, data)
      
      response = Braspag::Poster.new(self, self.url_for(method))
                                .do_post(method, data)
      
      response = Converter::from(method, response.body)
      
      args.each do |field|
        field.populate!(method, response)
      end
      
      response
    end
  end
end
