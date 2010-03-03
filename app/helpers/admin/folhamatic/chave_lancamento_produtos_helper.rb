module Admin::Folhamatic::ChaveLancamentoProdutosHelper

  # E221 CHAVE DO LANÇAMENTO DE PRODUTOS/SERVIÇOS
  # Este registro importará informações para o lançamento das notas fiscais de entradas e saídas, botão Lçto Produtos/Serviços, portanto, ao importar este registro as notas fiscais nele mencionadas já deverão estar lançadas no sistema ou constando nos Registros E200 e E201. 
  # Sempre que gerar um registro E221 gerar também um registro filho E222-LANÇAMENTO DE PRODUTOS/SERVIÇOS. 
  # A ordenação no aquivo para cada nota será o registro E221 (pai) e em seguida o(s) registro(s) E222 (filho). 
  # OBS: Poderá existir apenas um registro E221 por nota fiscal.
  def e221_chave_lancamento_produtos(pedido)
    return (e221_nome_do_registro +
            e221_saida +
            e221_especie_nf +
            e221_serie_nf +
            e221_subserie_nf +
            e221_numero_nf(pedido) +
            e221_codigo_cliente(pedido) +
            e221_frete +
            e221_seguro +
            e221_despesas_acessorias +
            e221_qtde_itens(pedido) +
            e221_pis_cofins +
            e221_peso_bruto +
            e221_peso_liquido +
            e221_via_transporte +
            e221_cod_transportador +
            e221_ident_veiculo1 +
            e221_ie_substituto_tributario +
            e221_qtde_volumes +
            e221_especie_dos_volumes +
            e221_ie_transportador +
            e221_estado_transportador +
            e221_estado_da_placa_veiculo1 +
            e221_ident_veiculo2 +
            e221_estado_da_placa_veiculo2 +
            e221_ident_veiculo3 +
            e221_estado_da_placa_veiculo3 +
            e221_local_saida_da_mercadoria +
            e221_cnpj_saida_da_mercadoria +
            e221_estado_saida_da_mercadoria +
            e221_ie_saida_da_mercadoria +
            e221_local_recebimento_da_mercadoria +
            e221_cnpj_recebimento_da_mercadoria +
            e221_estado_recebimento_da_mercadoria +
            e221_ie_recebimento_da_mercadoria +
            e221_uf_do_transportador +
            e221_controle_do_sistema)
  end
  
  # NOME DO REGISTRO - Informe E221 
  # Tipo: AlphaNum
  # Tam.: 4
  def e221_nome_do_registro
    return "E221"
  end

  # 2. ENTRADAS OU SAÍDAS - Informe "E" para nota fiscal de entrada ou "S" para nota fiscal de saída.
  # Tipo: AlphaNum
  # Tam.: 1
  def e221_saida
    return "S"
  end

  # 3. ESPÉCIE N.F.- Informe a espécie da nota fiscal
  # Tipo: AlphaNum X
  # Tam.: 5
  def e221_especie_nf
    return "%-5s" % "NF"
  end

  # 4. SÉRIE N.F. - Informe a série da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 3
  def e221_serie_nf
    return "%-3s" % "2"
  end

  # 5. SUBSÉRIE N.F.- Informe a subsérie da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 2
  def e221_subserie_nf
    return "%-2s" % ""
  end

  # 6. NÚMERO N.F. - Informe o número da nota fiscal.
  # Tipo: Num
  # Tam.: 10
  def e221_numero_nf(pedido)
    return "%010d" % pedido.nota_fiscal.to_i
  end

  # 7. CÓDIGO DO CLIENTE/FORNECEDOR - Informe o código do cliente ou fornecedor da nota fiscal conforme cadastro de clientes e fornecedores
  # Tipo: AlphaNum X
  # Tam.: 20
  def e221_codigo_cliente(pedido)
    if registrar_cliente?(pedido)
      return "%-20s" % codigo_cliente(pedido)
    else
      return "%-20s" % "19878" # 19878 = cliente padrao do escritorio do ARI
    end
  end

  # 8. FRETE - Informe o valor do frete da nota fiscal.
  # Tipo: Num
  # Tam.: 14
  def e221_frete
    return "%014d" % 0
  end

  # 9. SEGURO - Informe o valor do seguro da nota fiscal
  # Tipo: Num
  # Tam.: 14
  def e221_seguro
    return "%014d" % 0
  end

  # 10. DESPESAS ACESSÓRIAS - Informe o valor de outras despesas acessórias da nota fiscal.
  # Tipo: Num
  # Tam.: 14
  def e221_despesas_acessorias
    return "%014d" % 0
  end

  # 11. QUANTIDADE DE ITENS DA N.F. - Informe a quantidade de itens lançado na nota fiscal. 
  # Caso a nota não possua produtos/serviços, informar zeros neste campo e criar o registro filho E222 sem informações do produto/serviço.
  # Tipo: Num
  # Tam.: 3
  def e221_qtde_itens(pedido)
    return "%03d" % pedido.n_linhas_nota_fiscal
  end

  # 12. PIS/COFINS - Informe o valor de Pis e Cofins retido anteriormente (valor destacado na nota fiscal).
  # Tipo: Num
  # Tam.: 14
  def e221_pis_cofins
    return "%014d" % 0
  end

  # 13. PESO BRUTO - Informe o Peso Bruto das mercadorias (em quilogramas). Quando se tratar de cupom fiscal, zerar este campo.
  # Tipo: Num
  # Tam.: 13
  def e221_peso_bruto
    return "%013d" % 0
  end

  # 14. PESO LÍQUIDO - Informe o Peso Líquido das mercadorias (em quilogramas). Quando se tratar de cupom fiscal, zerar este campo.
  # Tipo: Num
  # Tam.: 13
  def e221_peso_liquido
    return "%013d" % 0
  end

  # 15. VIA DE TRANSPORTE - Informe a via de transporte da mercadoria, utilize os códigos abaixo: 
  # 0 - nennhum 
  # 1 - para via de transporte Rodoviário, 
  # 2 - para via de transporte Ferroviário, 
  # 3 - para via de transporte Rodo-Ferroviário, 
  # 4 - para via de transporte Aquaviário, 
  # 5 - para via de transporte Dutoviário, 
  # 6 - para via de transporte Aéreo 
  # 7 - para Outro. 
  # Quando se tratar de Cupom Fiscal, preencher com zero.
  # Tipo: Num
  # Tam.: 1
  def e221_via_transporte
    return "0"
  end

  # 16. CÓDIGO DO TRANSPORTADOR - Informe o código do transportador conforme cadastro de clientes e fornecedores. Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum X
  # Tam.: 20
  def e221_cod_transportador
    return "%-20s" % ""
  end

  # 17. IDENTIFICAÇÃO DO VEÍCULO (PLACA 1) - Informe a identificação do Veículo (ex. Placa (no formato AAANNNN), prefixo). Quando se tratar de cupom fiscal, preencher com espaços
  # Tipo: AlphaNum X
  # Tam.: 15
  def e221_ident_veiculo1
    return "%-15s" % ""
  end

  # 18. I.E. DO SUBSTITUTO TRIBUTÁRIO - Informe a Inscrição Estadual do Substituto Tributário no Estado de destino da mercadoria. Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum X
  # Tam.: 18
  def e221_ie_substituto_tributario
    return "%-18s" % ""
  end

  # 19. QTDE DE VOLUMES - Informe a quantidade de Volumes da nota fiscal. Quando se tratar de cupom fiscal, zerar este campo.
  # Tipo: Num
  # Tam.: 15
  def e221_qtde_volumes
    return "%015d" % 0
  end

  # 20. ESPÉCIE DOS VOLUMES - Informe a espécie de volume da nota fiscal, exemplo: caixa.
  # Quando se tratar de cupom fiscal, preencha este campo com espaços
  # Tipo: AlphaNum
  # Tam.: 10
  def e221_especie_dos_volumes
    return "%-10s" % ""
  end

  # 21. I.E. DO TRANSPORTADOR - Informe a Inscrição Estadual do Transportador caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 18
  def e221_ie_transportador
    return "%-18s" % ""
  end

  # 22. ESTADO DO TRANSPORTADOR - Informe o Estado do transportador caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 2
  def e221_estado_transportador
    return "%-2s" % ""
  end

  # 23. ESTADO DA PLACA DO VEÍCULO (PLACA 1) - Informe o Estado da Placa do Veículo. (estado da placa informada no campo 17). Este campo deverá ser informado se a Via de transporte for Rodoviário ou Rodo-Ferroviário, se a nota possuir produto classificado como  Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 2
  def e221_estado_da_placa_veiculo1
    return "%-2s" % ""
  end

  # 24. IDENTIFICAÇÃO DO VEÍCULO (PLACA 2) Informe a placa 2 do veículo (no formato AAANNNN) quando for utilizado veículo semi-reboque ou reboque. Este campo deverá ser informado se a via de transporte for Rodoviário ou Rodo-Ferroviário, se a nota possuir produto classificado como combustível/Solvente e se houve movimentação física da mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum X
  # Tam.: 15
  def e221_ident_veiculo2
    return "%-15s" % ""
  end

  # 25. ESTADO DA PLACA DO VEÍCULO (PLACA 2) - Informe o Estado da Placa 2 do veículo quando for utilizado veículo semi-reboque ou reboque. Este campo deverá ser informado se a Via de transporte for Rodoviário ou Rodo-Ferroviário, se a nota possuir produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 2
  def e221_estado_da_placa_veiculo2
    return "%-2s" % ""
  end

  # 26. IDENTIFICAÇÃO DO VEÍCULO (PLACA 3) Informe a placa 3 do veículo (no formato AAANNNN) quando for utilizado veículo semi-reboque ou reboque. Este campo deverá ser informado se a via de transporte for Rodoviário ou Rodo-Ferroviário, se a nota possuir produto classificado como combustível/Solvente e se houve movimentação física da mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum X
  # Tam.: 15
  def e221_ident_veiculo3
    return "%-15s" % ""
  end

  # 27. ESTADO DA PLACA DO VEÍCULO (PLACA 3) - Informe o Estado da Placa 3 do veículo quando for utilizado veículo semi-reboque ou reboque. Este campo deverá ser informado se  a Via de transporte for Rodoviário ou Rodo-Ferroviário, se a nota possuir produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 2
  def e221_estado_da_placa_veiculo3
    return "%-2s" % ""
  end

  # 28. LOCAL DE SAÍDA DA MERCADORIA - Informe "1" se a saída física da mercadoria aconteceu no estabelecimento do Emitente, e "2" se em outro estabelecimento. Este campo deverá ser informado caso a nota possua produto classificado como Combustível/Solvente e  se Houve Movimentação Física da Mercadoria, caso contrário, preencher com zero. 
  # Quando se tratar de cupom fiscal, preencher com zero.
  # Tipo: Num
  # Tam.: 1
  def e221_local_saida_da_mercadoria
    return "0"
  end

  # 29. CNPJ DA SAÍDA DA MERCADORIA - Informe o CNPJ do estabelecimento em que houve a saída física da mercadoria. Este campo deverá ser informado caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 14
  def e221_cnpj_saida_da_mercadoria
    return "%-14s" % ""
  end

  # 30. ESTADO DA SAÍDA DA MERCADORIA - Informe o Estado do estabelecimento em que houve a saída física da mercadoria. Este campo deverá ser informado caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 2
  def e221_estado_saida_da_mercadoria
    return "%-2s" % ""
  end

  # 31. I.E. DA SAÍDA DA MERCADORIA - Informe a Inscrição Estadual do estabelecimento em que houve a saída física da mercadoria. Este campo deverá ser informado caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da  Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 18
  def e221_ie_saida_da_mercadoria
    return "%-18s" % ""
  end

  # 32. LOCAL DE RECEBIMENTO DA MERCADORIA - Informe "1" se o recebimento físico da mercadoria aconteceu no estabelecimento do Destinatário, e "2" se em outro estabelecimento. Este campo deverá ser informado caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário,preencher com zero. 
  # Quando se tratar de cupom fiscal, preencher com zero.
  # Tipo: Num
  # Tam.: 1
  def e221_local_recebimento_da_mercadoria
    return "0"
  end

  # 33. CNPJ DO RECEBIMENTO DA MERCADORIA -Informe o CNPJ do estabelecimento em que houve o recebimento físico da mercadoria. Este campo deverá ser informado caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 14
  def e221_cnpj_recebimento_da_mercadoria
    return "%-14s" % ""
  end

  # 34. ESTADO DO RECEBIMENTO DA MERCADORIA - Informe o Estado do estabelecimento em que houve o recebimento físico da mercadoria. Este campo deverá ser informado caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 2
  def e221_estado_recebimento_da_mercadoria
    return "%-2s" % ""
  end

  # 35. I.E. DO RECEBIMENTO DA MERCADORIA - Informe a Inscrição Estadual do estabelecimento em que houve o recebimento físico da mercadoria. Este campo deverá ser informado caso a nota possua produto classificado como Combustível/Solvente e se Houve Movimentação Física da Mercadoria, caso contrário, preencher com espaços. 
  # Quando se tratar de cupom fiscal, preencher com espaços.
  # Tipo: AlphaNum
  # Tam.: 18
  def e221_ie_recebimento_da_mercadoria
    return "%-18s" % ""
  end

  # 36. UF DO TRANSPORTADOR
  # Tipo: AlphaNum
  # Tam.: 2
  def e221_uf_do_transportador
    return "%-2s" % ""
  end

  # 37. CONTROLE DO SISTEMA - Informe "0" (zero) para controle interno do Sistema E-Fiscal.
  # Tipo: Num
  # Tam.: 1
  def e221_controle_do_sistema
    return "0"
  end

end