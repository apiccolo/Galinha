module Admin::Folhamatic::ClientesHelper
  
  def e010_cadastro_de_cliente(pedido)
    return (e010_nome_do_registro +
            e010_codigo_do_cliente_fornecedor(pedido) +
            e010_nome(pedido) +
            e010_data_de_inclusao(pedido) +
            e010_tipo_de_logradouro(pedido) +
            e010_logradouro(pedido) +
            e010_numero_do_logradouro(pedido) +
            e010_complemento_do_logradouro(pedido) +
            e010_bairro(pedido) +
            e010_estado(pedido) +
            e010_cidade(pedido) +
            e010_cep(pedido) +
            e010_pais +
            e010_cnpj_cpf(pedido) +
            e010_inscricao_estadual +
            e010_inscricao_municipal +
            e010_inscricao_suframa +
            e010_contato(pedido) +
            e010_telefone(pedido) +
            e010_fax(pedido) +
            e010_data_da_alteração_cadastral(pedido) +
            e010_cliente +
            e010_fornecedor +
            e010_produtor_rural +
            e010_fornecedor_substituto +
            e010_simples_nacional +
            e010_inscrito_no_municipio)
  end

  # 01 NOME DO REGISTRO
  # Tipo: AlphaNum 
  # Tam.: 4
  def e010_nome_do_registro
    return "E010"
  end

  # 02 CÓDIGO DO CLIENTE/FORNECEDOR - Informe o código do cliente/fornecedor. Este código é de livre atribuição do estabelecimento e não poderá ser utilizado em duplicidade. Campo obrigatório.
  # Tipo: AlphaNum X
  # Tam.: 20
  def e010_codigo_do_cliente_fornecedor(pedido)
    return "%-20s" % codigo_cliente(pedido)
  end

  # 03 NOME - Informe o nome do Cliente/Fornecedor 
  # Tipo: AlphaNum X 
  # Tam.: 100
  def e010_nome(pedido)
    return "%-100s" % remover_acentos(pedido.pessoa.nome.upcase)
  end  
  
  # 04 DATA DE INCLUSÃO - Informe a Data de Inclusão no formato AAAAMMDD dos dados do cliente/Fornecedor no cadastro.
  # Tipo: Num
  # Tam.: 8
  def e010_data_de_inclusao(pedido)
    return "%-8s" % pedido.created_at.strftime("%Y%m%d")
  end
  
  # 05 TIPO DE LOGRADOURO - Informe o tipo de logradouro do Cliente/Fornecedor, exemplo: Rua, Av., etc.... O preenchimento deste campo é obrigatório. 
  # OBS: Na Tabela de Tipos de Logradouro existem alguns tipos de logradouro.
  # Tipo: AlphaNum
  # Tam.: 15
  def e010_tipo_de_logradouro(pedido)
    r = "RUA"
    return "%-15s" % r
  end

  # 06 LOGRADOURO - Informe o Logradouro do cliente/fornecedor.
  # Tipo: AlphaNum X 
  # Tam.: 100
  def e010_logradouro(pedido)
    return "%-100s" % "CAMARGO PIMENTEL"
  end
  
  # 07 NÚMERO DO LOGRADOURO - Informe o número do logradouro. 
  # Tipo: AlphaNum X
  # Tam.: 10
  def e010_numero_do_logradouro(pedido)
    return "%-10s" % "15"
  end
  
  # 08 COMPLEMENTO DO LOGRADOURO - Informe o complemento do logradouro. 
  # OBS: Se o campo País for diferente de Brasil, a informação do estado e da cidade podem ser informados neste campo.
  # Tipo: AlphaNum X
  # Tam.: 50
  def e010_complemento_do_logradouro(pedido)
    return "%-50s" % ""
  end
    
  # 09 BAIRRO - Informe o bairro do Cliente/Fornecedor. 
  # Tipo: AlphaNum X 
  # Tam.: 30
  def e010_bairro(pedido)
    return "%-30s" % "JARDIM GUANABARA"
  end

  # 10 ESTADO - Informe o estado do Cliente/Fornecedor. Informe EX quando o cliente for do exterior e IM quando o fornecedor for do exterior.
  # Tipo: AlphaNum 
  # Tam.: 2
  def e010_estado(pedido)
    return "%-2s" % "SP"
  end
  
  # 11 CIDADE - Informe o código da cidade do cliente/fornecedor conforme Tabela de Municípios-IBGE. Quando o cliente/fornecedor for do exterior, informe zeros.
  # Tipo: Num
  # Tam.: 7
  def e010_cidade(pedido)
    return "%07d" % 3509502
  end

  # 12 CEP - Informe o CEP do Cliente/Fornecedor.
  # Tipo: Num
  # Tam.: 8
  def e010_cep(pedido)
    return "%08d" % 13073340
  end

  # 13 PAÍS - Informe código do País do Cliente/Fornecedor conforme Tabela de Códigos de Países. 
  # Tipo: Num 
  # Tam.: 5
  def e010_pais
    return "%05d" % 1058
  end

  # 14 CNPJ/CPF - Informe o CNPJ/CPF do cliente/fornecedor. 
  # No caso de informação de CPF deixar espaços à direita até o complemento do tamanho. 
  # OBS.: Para CPF, a quantidade mínima de números é 11. Este campo não será obrigatório quando o campo país for diferente
  # de Brasil, caso contrário será obrigatório. Não poderá existir CNPJ/CPF duplicado, mesmo
  # que o código do cliente/fornecedor seja diferente.
  # Tipo: AlphaNum 
  # Tam.: 14
  def e010_cnpj_cpf(pedido)
    return "%-14s" % pedido.pessoa.cpf
  end

  # 15 INSCRIÇÃO ESTADUAL - Informe a Inscrição Estadual do cliente/fornecedor. 
  # Tipo: AlphaNum X 
  # Tam.: 18
  def e010_inscricao_estadual
    return "%-18s" % ""
  end
  
  # 16 INSCRIÇÃO MUNICIPAL - Informe o número da Inscrição Municipal do Cliente/Fornecedor caso o mesmo possua. Caso não possua preencher com espaços
  # Tipo: AlphaNum
  # Tam.: 14
  def e010_inscricao_municipal
    return "%-14s" % ""
  end
  
  # 17 INSCRIÇÃO SUFRAMA - Informe a Inscrição Suframa.
  # Tipo: AlphaNum X
  # Tam.: 9
  def e010_inscricao_suframa
    return "%-9s" % ""
  end
  
  # 18 CONTATO - Informe o nome do contato com cliente/fornecedor.
  # Tipo: AlphaNum X 
  # Tam.: 35
  def e010_contato(pedido)
    return "%-35s" % contato_cliente(pedido)
  end
  
  # 19 TELEFONE - Informe o telefone do Cliente/Fornecedor no formato (99)9999-9999 ou (99)9999-9999999
  # Tipo: AlphaNum X
  # Tam.: 16
  def e010_telefone(pedido)
    return "%-16s" % "(19)3241-5135"
  end
  
  # 20 FAX - Informe o fax do cliente/fornecedor no formato (99)9999-9999 ou (99)9999-9999999 
  # Tipo: AlphaNum X
  # Tam.: 16
  def e010_fax(pedido)
    return "%-16s" % "(19)3241-5135"
  end
  
  # 21. DATA DA ALTERAÇÃO CADASTRAL NO SISTEMA E-FISCAL - Informe este campo apenas quando o cadastro do cliente/fornecedor sofreu alterações cadastrais (ex: mudou de endereço). Neste caso, preencha com a data em que o cadastro foi alterado no formato AAAAMMDD. 
  # Quando se tratar de uma alteração ortográfica ou inclusão de novo cadastro, não preencher este campo. 
  # Fique atento quanto as instruções no início do registro.
  # Tipo: Data (AAAAMMDD)
  # Tam.: 8
  def e010_data_da_alteração_cadastral(pedido)
    return "%-8s" % ""
  end
  
  # 22 CLIENTE - Preencher com "S" caso o cadastro seja de um cliente ou com "N" caso não seja. 
  # Tipo: AlphaNum
  # Tam.: 1
  def e010_cliente
    return "S"
  end

  # 23 FORNECEDOR - Preencher com "S" caso o cadastro seja de um fornecedor ou com "N" caso não seja.
  # Tipo: AlphaNum
  # Tam.: 1
  def e010_fornecedor
    return "N"
  end
  
  # 24 PRODUTOR RURAL - Informe "S" caso o cadastro seja de um cliente/fornecedor produtor rural, ou "N" caso não seja.
  # Tipo: AlphaNum 
  # Tam.: 1
  def e010_produtor_rural
    return "N"
  end
  
  # 25 FORNECEDOR SUBSTITUTO TRIBUTÁRIO - Preencher com "S" caso o fornecedor recolha o ICMS na condição de Substituto Tributário. Preencher com "N" caso não recolha ou se tratando de cliente.
  # Tipo: AlphaNum
  # Tam.: 1
  def e010_fornecedor_substituto
    return "N"
  end
  
  # 26 SIMPLES NACIONAL - Preencher com "S" se o cliente/fornecedor estiver enquadrado no Simples Nacional ou com "N" caso não esteja. 
  # OBS. Essa informação é para fins de geração do arquivo municipal "ISS Digital", sendo assim, para empresas que não utilizam essa geração, preencher sempre com "N".
  # Tipo: AlphaNum 
  # Tam.: 1
  def e010_simples_nacional
    return "N"
  end
  
  # 27 INSCRITO NO MUNICÍPIO - Preencher com "S" se o cliente/fornecedor for inscrito no município da empresa que irá gerar o ISS Digital ou com "N" caso não seja inscrito. 
  # OBS. Essa informação é para fins de geração do arquivo municipal "ISS Digital", sendo assim, para empresas que não utilizam essa geração, preencher sempre com "N".
  # Tipo: AlphaNum
  # Tam.: 1
  def e010_inscrito_no_municipio
    return "N"
  end
  
  #=================================#
  #  METODOS q integram FOLHAMATIC  #
  #=================================#
  def codigo_cliente(pedido)
    pedido.pessoa.id.to_s + "SG"
  end
  
  def registrar_cliente?(pedido)
    return (not (pedido.pessoa.cpf.blank?))
  end
  
  def contato_cliente(pedido)
    # máximo de 35 chars
    if pedido.pessoa.fone_ddd and pedido.pessoa.fone_str
      r = "#{truncate(pedido.pessoa.nome,20)} (#{pedido.pessoa.fone_ddd})#{pedido.pessoa.fone_str}"
    else
      r = pedido.pessoa.nome
    end
    return remover_acentos(truncate(r, 35))
  end
  
  def remover_acentos(texto)
    return texto if texto.blank?
    texto = texto.gsub(/[á|à|ã|â|ä]/, 'a').gsub(/(é|è|ê|ë)/, 'e').gsub(/(í|ì|î|ï)/, 'i').gsub(/(ó|ò|õ|ô|ö)/, 'o').gsub(/(ú|ù|û|ü)/, 'u')
    texto = texto.gsub(/(Á|À|Ã|Â|Ä)/, 'A').gsub(/(É|È|Ê|Ë)/, 'E').gsub(/(Í|Ì|Î|Ï)/, 'I').gsub(/(Ó|Ò|Õ|Ô|Ö)/, 'O').gsub(/(Ú|Ù|Û|Ü)/, 'U')
    texto = texto.gsub(/ñ/, 'n').gsub(/Ñ/, 'N')
    texto = texto.gsub(/ç/, 'c').gsub(/Ç/, 'C')
    texto
  end
end