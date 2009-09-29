require 'rubygems'
require 'braspag_cryptography'
require 'braspag_layout'

class Braspag
  def self.layout(:identifier, :min_length, :max_length, params = {})
    BraspagLayout.new(:identifier, :min_length, :max_length, params)
  end

  @@model = {
              :identificacao => {
                :id           => layout('Id_Loja'   , 38,  38, :allow_blank => false), # Formato: {00000000-0000-0000-0000-000000000000}
                :transacao    => layout('VENDAID'   ,  1,  50, :allow_blank => false), # Número do pedido
                :valor        => layout('VALOR'     ,  1,  10, :allow_blank => false) # Valor total do pedido em centavos (ex.: R$1,00 = 100)
              },
              :comprador => {
                :nome         => layout('NOME'      ,  1, 255, :allow_blank => false), # Nome do Comprador
                :cpf          => layout('CPF'       , 11,  14), # CPF do Comprador (se pessoa física)
                :razao_social => layout('RAZAO_PJ'  ,  1, 255), # Nome da empresa (Se pessoa jurídica)
                :cnpj         => layout('CNPJ'      , 14,  18), # Número do CNPJ (se pessoa jurídica)
                :dt_nascimento=> layout('NASC'      , 10,  10), # Data nascimento do Comprador (formato: dd/mm/aaaa)
                :estado_civil => layout('ESTCIVIL'  ,  1,   1), # Estado civil do Comprador (Solteiro = S; Casado = C; Divorciado = D; Viúvo = V; Outro = O)
                :sexo         => layout('SEXO'      ,  1,   1), # Sexo do comprador (M ou F)
                :profissao    => layout('PROF'      ,  1, 255), # Profissão do Comprador
                :telefone     => layout('FONE'      ,  1,  64), # Número do telefone do Comprador (para Oi Paggo, enviar Celular com DDD neste campo)
                :fax          => layout('FAX'       ,  1,  64), # Número do fax do Comprador
                :email        => layout('EMAIL'     ,  1, 255), # E-mail do comprador
                :endereco_cobranca => {
                  :logradouro  => layout('LOGRADOURO' ,  1, 255), # Logradouro do Comprador (ex: Rua, Avenida, Estrada...)
                  :endereco    => layout('ENDERECO'   ,  1, 255), # Endereço do Comprador (ex: nome da rua)
                  :numero      => layout('NUMERO'     ,  1, 10 ), # Número do endereço do Comprador
                  :complemento => layout('COMPLEMENTO',  1, 50 ), # Complemento do endereço do Comprador
                  :bairro      => layout('BAIRRO'     ,  1, 255), # Bairro do Comprador
                  :cidade      => layout('CIDADE'     ,  1, 255), # Cidade do Comprador
                  :cep         => layout('CEP'        ,  8, 9  ), # CEP do Comprador
                  :estado      => layout('ESTADO'     ,  2, 2  ), # Estado (UF) do Comprador
                  :pais        => layout('PAIS'       ,  1, 255)  # País do Comprador
                },
                :endereco_entrega => {
                  :logradouro  => layout('LOGRADOURO_D' ,1, 255), # Logradouro de Entrega (ex: Rua, Avenida, Estrada...)
                  :endereco    => layout('ENDERECO_D'   ,1, 255), # Endereço de Entrega (ex: nome da rua)
                  :numero      => layout('NUMERO_D'     ,1, 10 ), # Número do endereço de Entrega
                  :complemento => layout('COMPLEMENTO_D',1, 50 ), # Complemento do endereço de Entrega
                  :bairro      => layout('BAIRRO_D'     ,1, 255), # Bairro de Entrega
                  :cidade      => layout('CIDADE_D'     ,1, 255), # Cidade de Entrega
                  :cep         => layout('CEP_D'        ,8, 9  ), # CEP de Entrega
                  :estado      => layout('ESTADO_D'     ,2, 2  ), # Estado (UF) de Entrega
                  :pais        => layout('PAIS_D'       ,1, 255)  # País de Entrega
                }
              },
              :operacao => {
                :financiamento      => layout('Extrafinanciamento', 1, 512), # Logradouro de Entrega (ex: Rua, Avenida, Estrada...)
                :moeda              => layout('MOEDA'             , 3, 3), # Endereço de Entrega (ex: nome da rua)
                :tipo_pagamento     => layout('CODPAGAMENTO'      , 2, 3), # Número do endereço de Entrega
                :parcelas           => layout('PARCELAS'          , 1, 2), # Complemento do endereço de Entrega
                :tipo_parcelamento  => layout('TIPOPARCELADO'     , 1, 1), # Bairro de Entrega
                :recorrente => {
                  :data_inicio      => layout('DATAINICIO'          , 10,  10), # Data programada para a primeira cobrança
                  :data_termino     => layout('DATAFIM'             , 10,  10), # Data programada para última cobrança
                  :intervalo        => layout('INTERVALORECORRENCIA',  1,  10), # De quantos em quanto meses haverá débito
                  :nome_portador    => layout('NOMEPORTADOR'        ,  1, 255), # Nome do portador do cartão
                  :numero_cartao    => layout('NUMEROCARTAO'        ,  1,  10), # Numero do cartão de crédito
                  :validade         => layout('VALIDADE'            , 10,  10), # Validade do cartão. Formato: dd/mm/aaaa
                  :codigo_seguranca => layout('CODIGOSEGURANCA'     ,  1,   3)  # Código de segurança do cartão
                }
              }
              #,:extra => {}
            }
end

=begin

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


CODPAGAMENTO  Identificação da forma de pagamento (Tabela 3)  2    3     Sim
              número de parcelas em que o valor total será
   PARCELAS                                                   1    2     Não
              dividido (padrão = 1)
TIPOPARCELADO Com juros enviar “1”. Sem juros enviar “0”      1    1     Não


=end
