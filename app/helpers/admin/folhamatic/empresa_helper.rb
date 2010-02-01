module Admin::Folhamatic::EmpresaHelper

  #ATENÇÃO: Este registro é obrigatório, em uma única vez em cada arquivo, sempre que for gerar qualquer outro registro do layout. 
  # O mesmo existe para que o sistema identifique para qual empresa deverá importar os dados.
  # Não é necessário repetir o registro E001 no arquivo mais que uma vez (para a mesma empresa) quando vários períodos de lançamentos
  def e001_identificacao_da_empresa
    return (e001_nome_do_registro + 
            e001_numero_da_empresa + 
            e001_versao_layout + 
            e001_controle_do_sistema)
  end

  # NOME DO REGISTRO - Informe E001
  # Tipo: AlphaNum
  # Tam.: 4
  def e001_nome_do_registro
    return "E001"
  end
  
  # NÚMERO DA EMPRESA - Número que a empresa está cadastrada no sistema Efiscal a
  # qual se refere os dados do arquivo
  # Tipo: Num
  # Tam.: 4
  def e001_numero_da_empresa
    return "0105"
  end
  
  # VERSÃO LAYOUT - Informe o nº da versão do layout que está sendo utilizado para gerar o
  # arquivo, o qual encontra-se no cabeçalho do layout. Exemplo: 2.0
  # Tipo: AlphaNum X
  # Tam.: 3
  def e001_versao_layout
    return "2.0"
  end
  
  # CONTROLE DO SISTEMA - Informe "0" (zero) para controle interno do Sistema E-Fiscal.
  # Tipo: Num
  # Tam.: 1
  def e001_controle_do_sistema
    return "0"
  end

end