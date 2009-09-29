require 'rubygems'
require 'braspag_cryptography'
require 'braspag_layout'

class Braspag
  def self.layout(:identifier, :min_length, :max_length, params = {})
    BraspagLayout.new(:identifier, :min_length, :max_length, params)
  end

  @@model = { :comprador => {
                              :nome => layout('NOME', 1, 255, :allow_blank => false),
                              :cpf => layout('CPF', 11, 14, :allow_blank => false)
                            }

  }

end
=begin
      Id_Loja                                                                   38  38 Sim
                      Formato: {00000000-0000-0000-0000-000000000000}
     VENDAID                               Número do pedido                      1  50 Sim
       VALOR          Valor total do pedido em centavos (ex.: R$1,00 = 100)            Sim
       NOME                               Nome do Comprador                      1 255 Sim
         CPF                    CPF do Comprador (se pessoa física)             11  14 Não
    RAZAO_PJ                   Nome da empresa (Se pessoa jurídica)              1 255 Não
        CNPJ                    Número do CNPJ (se pessoa jurídica)             14  18 Não
  LOGRADOURO         Logradouro do Comprador (ex: Rua, Avenida, Estrada...)      1 255 Não
    ENDERECO                 Endereço do Comprador (ex: nome da rua)             1 255 Não
     NUMERO                      Número do endereço do Comprador                       Não
  COMPLEMENTO                 Complemento do endereço do Comprador                     Não
      BAIRRO                              Bairro do Comprador                    1 255 Não
      CIDADE                             Cidade do Comprador                     1 255 Não
         CEP                               CEP do Comprador                      8   9 Não
     ESTADO                            Estado (UF) do Comprador                  2   2 Não
        PAIS                               País do Comprador                     1 255 Não
       NASC          Data nascimento do Comprador (formato: dd/mm/aaaa)         10  10 Não
                        Estado civil do Comprador (Solteiro = S; Casado = C;
     ESTCIVIL                                                                    1   1 Não
                               Divorciado = D; Viúvo = V; Outro = O)
       SEXO                           Sexo do comprador (M ou F)                 1   1 Não
        PROF                            Profissão do Comprador                   1 255 Não
                     Número do telefone do Comprador (para Oi Paggo, enviar
       FONE                                                                      1  64 Não
                                    Celular com DDD neste campo)
         FAX                         Número do fax do Comprador                  1  64 Não
       EMAIL                              E-mail do comprador                    1 255 Não
                       Logradouro do endereço de entrega (ex: Rua, Avenida,
 LOGRADOURO_D                                                                    1 255 Não
                                                Estada...)
   ENDERECO_D                             Endereço de entrega                    1 255 Não
    NUMERO_D                       Número do endereço de entrega                       Não
COMPLEMENTO_D                  Complemento do endereço de entrega                      Não
    BAIRRO_D                                Bairro de entrega                    1 255 Não
    CIDADE_D                               Cidade de entrega                     1 255 Não
       CEP_D                                 CEP de entrega                      8   9 Não
    ESTADO_D                            Estado de entrega (UF)                   2   2 Não
      PAIS_D                                 Pais de entrega                     1 255 Não
                   Descrição do objeto financiado. Obs.: No caso de carrinho de
Extrafinanciamento                                                               1 512 Não
                      compras utilizar a descrição do produto de maior valor.
                    Moeda utilizada na venda seguindo o ISO 4217 (USD, GBP,
      MOEDA        JPY, CAD, AUD, EUR) Campo Obrigatório apenas para o meio      3   3 Não
                         de pagamento PayPal e não necessário para outros.
                   Informação adicional que a loja deseje associar à transação.
 EXTRA[nome que      Este parâmetro nunca é retornado, ele somente pode ser
você deseja dar ao    acessado pelo ambiente Administrativo (backoffice). Se     1 768 Não
      campo]          enviado parâmetro com nome “ExtraInfo“, no backoffice
                                            aparecerá “Info”
=end
