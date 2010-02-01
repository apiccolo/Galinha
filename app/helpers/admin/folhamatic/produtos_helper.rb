module Admin::Folhamatic::ProdutosHelper

  # REGISTRO: E020- CADASTRO DE PRODUTOS/SERVIÇOS
  # Este registro importará os dados para o Cadastro de Produtos/Serviços do sistema. Atenção para as observações abaixo:
  # - Se o cadastro do produto/serviço já existir no sistema, ao importar, os dados do mesmo serão sobrepostos.
  # - Se foram feitas alterações do tipo ortográficas (corretivas) no cadastro, importe o registro E020 deixando os campos 05 e 07 vazios, preenchendo no campo 06 a data do Período Inicial de Utilização do produto/serviço.
  # - Se o cadastro do produto/serviço sofreu alterações cadastrais (ex. alteração na descrição), gere um registro E020 com os dados já atualizados e
  # com os campos 05 e 07 vazios, preenchendo no campo 06 a data do Período Inicial de Utilização do produto/serviço, e gere também um registro
  # E020 com os dados anteriores informando nos campos 06 e 07 a data inicial e final dos dados anteriores. Quando a alteração cadastral for na
  # descrição do produto/serviço, informe também no campo 05 a data em que o cadastro sofreu a alteração, caso contrário, deixe este campo vazio.
  def e020_cadastro_de_produtos_servicos
    return "implementar, se preciso"
  end

end