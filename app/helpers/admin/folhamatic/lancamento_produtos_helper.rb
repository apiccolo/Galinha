module Admin::Folhamatic::LancamentoProdutosHelper

  # E222 LANÇAMENTO DE PRODUTOS/SERVIÇOS
  # Este registro importará informações referente os lançamentos dos produtos/serviços da nota fiscal e serão importadas para as linhas de lançamento do botão Lçto Produtos/Serviços. 
  # Sempre que gerar um registro E222 gerar também um registro pai E221- CHAVE DO LANÇAMENTO DE PRODUTOS/SERVIÇOS. 
  # Após importado, a ordem das linhas de lançamento dos produtos serão apresentadas no sistema conforme a ordem deste registro E222 no arquivo. 
  # OBS: Poderão existir vários registros E222 para cada E221. 
  # ATENÇÃO: Para montar o arquivo, o registro E221 deverá estar sempre na sequência de um E222. 
  # Exemplo: 
  #     E221 referente NF 0150 
  #     E222 referente item 001 
  #     E222 referente item 002 
  #     E221 referente NF 0151 
  #     E222 referente item 001 
  #     E222 referente item 002
  def e222_lancamento_produtos(pedido, pq, produto_do_combo=nil, k=nil)
    return (e222_nome_do_registro +
            e222_saida +
            e222_especie_nf +
            e222_serie_nf +
            e222_subserie_nf +
            e222_numero_nf(pedido) +
            e222_codigo_cliente(pedido) +
            e222_numero_item(pedido, k) +
            e222_cfop(pedido) +
            e222_codigo_do_produto(pedido, pq, produto_do_combo) +
            e222_aliquota_icms +
            e222_quantidade(pedido, pq) +
            e222_valor_mercadoria(pedido, pq, produto_do_combo, k) +
            e222_valor_desconto(pedido, pq, produto_do_combo, k) +
            e222_base_calculo_icms +
            e222_base_subst_trib +
            e222_valor_ipi +
            e222_valor_unitario(pedido, pq, produto_do_combo, k) +
            e222_numero_di +
            e222_base_calculo_ipi +
            e222_valor_do_icms +
            e222_isentos_de_icms +
            e222_outros_de_icms +
            e222_numero_coo +
            e222_icms_subst_trib_produto +
            e222_movimentacao_fisica_mercadoria +
            e222_isentos_de_ipi +
            e222_outros_de_ipi +
            e222_base_st_na_origem_destino +
            e222_icms_st_a_repassar +
            e222_icms_st_a_complementar +
            e222_item_cancelado +
            e222_op_merc_suj_reg_subst_trib_saida +
            e222_iss +
            e222_codigo_unidade_comercial +
            e222_codigo_natureza_operacao +
            e222_descricao_complementar_do_produto +
            e222_fator_conversao +
            e222_aliquota_icms_st +
            e222_sit_trib_icms_tab_a +
            e222_sit_trib_icms_tab_b +
            e222_sit_trib_ipi +
            e222_apuracao_distintas_do_ipi +
            e222_codigo_da_conta +
            e222_frete +
            e222_frete_no_total_da_nf +
            e222_seguro +
            e222_seguro_no_total_da_nf +
            e222_despesas_acessorias +
            e222_despesas_acessorias_no_total_da_nf +
            e222_acrescimo +
            e222_reducao_base_calculo_icms +
            e222_valor_nao_tributado +
            e222_quantidade_cancelada +
            e222_base_icms_reduzida + 
            e222_dados_para_redef_nf_paulista +
            e222_numero_do_totalizador +
            e222_controle_do_sistema)
  end

  # 1. NOME DO REGISTRO - Informe E222
  # Tipo: AlphaNum
  # Tam.: 4
  def e222_nome_do_registro
    return "E222"
  end

  # 2. ENTRADAS OU SAÍDAS - Informe "E" para nota fiscal de entrada ou "S" para nota fiscal de saída.
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_saida
    return "S"
  end

  # 3. ESPÉCIE N.F.- Informe a espécie da nota fiscal
  # Tipo: AlphaNum X
  # Tam.: 5
  def e222_especie_nf
    return "%-5s" % "NF"
  end

  # 4. SÉRIE N.F. - Informe a série da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 3
  def e222_serie_nf
    return "%-3s" % "2"
  end

  # 5. SUBSÉRIE N.F.- Informe a subsérie da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 2
  def e222_subserie_nf
    return "%-2s" % ""
  end

  # 6. NÚMERO N.F. - Informe o número da nota fiscal.
  # Tipo: Num
  # Tam.: 10
  def e222_numero_nf(pedido)
    return "%010d" % pedido.nota_fiscal.to_i
  end

  # 7. CÓDIGO DO CLIENTE/FORNECEDOR - Informe o código do cliente ou fornecedor da nota fiscal conforme cadastro de clientes e fornecedores
  # Tipo: AlphaNum X
  # Tam.: 20
  def e222_codigo_cliente(pedido)
    if registrar_cliente?(pedido)
      return "%-20s" % codigo_cliente(pedido)
    else
      return "%-20s" % "19878" # 19878 = cliente padrao do escritorio do ARI
    end
  end

  # 8. Nº ITEM - Informe o número de ordem do item na nota fiscal começando pelo número 001. 
  # OBS: O validador do arquivo magnético SINTEGRA (Convênios 69/02 e 142/02) não aceita que o produto seja de itens 991 a 999.
  # Tipo: Num
  # Tam.: 3
  def e222_numero_item(pedido, k)
    if k
      item = k+1
    else
      item = 1
    end
    return "%03d" % item
  end

  # 9. CFOP - Informe o CFOP do item. 
  # Ex. 1101, 5101
  # Tipo: AlphaNum
  # Tam.: 4
  def e222_cfop(pedido)
    if (pedido.entrega_estado=="SP")
      return "%04d" % 5102
    else
      return "%04d" % 6102
    end
  end

  # 10. CÓDIGO DO PRODUTO/SERVIÇO - Informe o código do produto/serviço conforme cadastro de Produtos/Serviços.
  # Tipo: AlphaNum X
  # Tam.: 14
  def e222_codigo_do_produto(pedido, pq, produto_do_combo)
    if produto_do_combo
      id = produto_do_combo.id
    else
      id = pq.produto_id
    end
    return "%-14s" % id
  end
  
  # 11. ALÍQUOTA DO ICMS - Informe a aliquota de ICMS do produto/serviço. Exemplo: alíquota de 18% informar no arquivo 0180000.
  # Tipo: Num
  # Tam.: 7
  def e222_aliquota_icms
    return "%07d" % 0
  end

  # 12. QUANTIDADE - Informe a quantidade do produto/serviço.
  # Tipo: Num
  # Tam.: 15
  def e222_quantidade(pedido, pq)
    return "%015d" % (pq.qtd.to_i * 100000)
  end

  # 13. VLR.MERCADORIA/SERVIÇO - Informe o valor da mercadoria/serviço. Deve ser o valor bruto do produto/serviço (valor unitário x quantidade).
  # Tipo: Num
  # Tam.: 14
  def e222_valor_mercadoria(pedido, pq, produto_do_combo, k)
    if produto_do_combo # se esse parametro existe, sabemos que eh um ProdutoSimples integrante do combo
      preco_sem_ponto = sprintf("%.2f", produto_do_combo.preco_fiscal * pq.qtd ).delete(".").to_i
    else # se nao, eh um ProdutoSimples comprado separadamente
      preco_sem_ponto = sprintf("%.2f", pq.produto.preco_fiscal * pq.qtd ).delete(".").to_i
    end  
    return "%014d" % preco_sem_ponto
  end

  # 14. VALOR DO DESCONTO - Informe o valor do desconto concedido no item.
  # Tipo: Num
  # Tam.: 14
  def e222_valor_desconto(pedido, pq, produto_do_combo, k)
    desconto = 0 
    if produto_do_combo and k
      desconto = sprintf("%.2f", pq.produto.desconto).delete(".").to_i if (k == 0)
      # aplicar o desconto para o primeiro item do combo
    end
    return "%014d" % desconto
  end

  # 15. BASE DE CÁLCULO DO ICMS - Informe o valor da base de cálculo do ICMS do produto/serviço. 
  # OBS. Quando se tratar de Base de cálculo reduzida, informe o valor da Base sem a redução.
  # Tipo: Num
  # Tam.: 14
  def e222_base_calculo_icms
    return "%014d" % 0
  end
  
  # 16. BASE SUBST. TRIB. - Informe o valor da base de cálculo do ICMS da substituição tributária do produto/serviço. 
  # Quando se tratar de cupom fiscal, zerar este campo.
  # Tipo: Num
  # Tam.: 14
  def e222_base_subst_trib
    return "%014d" % 0
  end

  # 17. VALOR DO IPI - Informe o valor de IPI do produto/serviço. 
  # Quando se tratar de cupom fiscal, zerar este campo.
  # Tipo: Num
  # Tam.: 14
  def e222_valor_ipi
    return "%014d" % 0
  end

  # 18. VALOR UNITÁRIO - Informe o valor unitário do produto/serviço.
  # Tipo: Num
  # Tam.: 14
  def e222_valor_unitario(pedido, pq, produto_do_combo, k)
    if produto_do_combo and k
      if (k==0) # aplicar o desconto para o primeiro item do combo
        valor_unitario = sprintf("%.2f", produto_do_combo.preco_fiscal - pq.produto.desconto).delete(".").to_i
      else
        valor_unitario = sprintf("%.2f", produto_do_combo.preco_fiscal).delete(".").to_i
      end
    else
      valor_unitario = sprintf("%.2f", pq.produto.preco_fiscal).delete(".").to_i
    end
    return "%014d" % (valor_unitario * 100)
  end

  # 19. Nº D.I. - Informe o número da DI (Declaração de importação) quando se tratar de nota fiscal de importação (CFOP 3.xxx).
  # Tipo: Num
  # Tam.: 10
  def e222_numero_di
    return "%010d" % 0
  end

  # 20. BC DO IPI - Informe o valor da Base de Cálculo do IPI do produto/serviço. Quando se tratar de cupom fiscal, zerar este campo.
  # Tipo: Num
  # Tam.: 14
  def e222_base_calculo_ipi
    return "%014d" % 0
  end
  
  # 21. VALOR DO ICMS - Informe o valor de ICMS do produto/serviço.
  # Tipo: Num
  # Tam.: 14
  def e222_valor_do_icms
    return "%014d" % 0
  end

  # 22. ISENTOS DE ICMS - Quando o lançamento for de cupom fiscal, informe o valor Isento de ICMS do produto/serviço, caso contrário, informe zeros.
  # Tipo: Num
  # Tam.: 14
  def e222_isentos_de_icms
    return "%014d" % 0
  end

  # 23. OUTROS DE ICMS - Quando o lançamento for de cupom fiscal, informe o valor Outros de ICMS do produto/serviço, caso contrário, informe zeros.
  # Tipo: Num
  # Tam.: 14
  def e222_outros_de_icms
    return "%014d" % 0
  end

  # 24. Nº COO - Informe o número do cupom fiscal (COO-Contador de Ordem de Operação), caso contrário, informe zeros.
  # Tipo: Num
  # Tam.: 10
  def e222_numero_coo
    return "%010d" % 0
  end

  # 25. ICMS SUBST. TRIB. - Informe o valor do ICMS Substituição Tributária do produto/serviço
  # Tipo: Num
  # Tam.: 14
  def e222_icms_subst_trib_produto
    return "%014d" % 0
  end
  
  # 26. MOVIMENTAÇÃO FÍSICA DA MERCADORIA - Informe "S" se houve movimentação física da mercadoria, ou "N" se não houve.
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_movimentacao_fisica_mercadoria
    return "N"
  end

  # 27. ISENTOS DE IPI - Informe o valor Isento de IPI do produto/serviço. Quando se tratar de cupom fiscal, zerar este campo.
  # Tipo: Num
  # Tam.: 14
  def e222_isentos_de_ipi
    return "%014d" % 0
  end

  # 28. OUTROS DE IPI - Informe o valor Outros de IPI do produto/serviço. Quando se tratar de cupom fiscal, zerar este campo.
  # Tipo: Num
  # Tam.: 14
  def e222_outros_de_ipi
    return "%014d" % 0
  end

  # 29. BASE ST NA ORIGEM/DESTINO - Informe a base de cálculo utilizada para a substituição tributária na unidade federada de origem e registrada no campo: 'Informações Complementares' da Nota Fiscal; previsão contida nas cláusulas 'nona', 'décima' e 'décima A' (Convênio ICMS 03/99, alterado pelo 138/01), somente para operações com combustíveis, quando o imposto devido à unidade federada de destino for diverso do imposto cobrado na unidade federada de origem.
  # OBS. Se a empresa utiliza a geração da EFD - Escrituração Fiscal Digital informe este campo nos casos acima, mesmo que o produto NÃO seja combustível".
  # Tipo: Num
  # Tam.: 14
  def e222_base_st_na_origem_destino
    return "%014d" % 0
  end

  # 30. ICMS-ST A REPASSAR - Informe o valor do imposto que deverá ser deduzido da UF de origem e repassado à UF de destino.  Previsão contida nas cláusulas 'nona', 'décima' e 'décima A' (Convênio ICMS 03/99, alterado pelo 138/01), somente para operações com combustíveis, quando o imposto devido à unidade federada de destino for diverso do imposto cobrado na unidade federada de origem.
  # OBS. Se a empresa utiliza a geração da EFD - Escrituração Fiscal Digital informe este campo nos casos acima, mesmo que o produto NÃO seja combustível".
  # Tipo: Num
  # Tam.: 14
  def e222_icms_st_a_repassar
    return "%014d" % 0
  end
  
  # 31. ICMS-ST A COMPLEMENTAR - Informe o valor do imposto relativo à diferença entre o repassado pela refinaria e o devido no estado de destino (em qualquer ponto da cadeia de comercialização), se for o caso. Previsão contida nas cláusulas 'nona', 'décima' e 'décima A' (Convênio ICMS 03/99, alterado pelo Convênio ICMS 138/01), somente para operações com combustíveis, quando o imposto devido à Unidade da Federação de destino for diverso do imposto cobrado na UF de origem. 
  # OBS. Se a empresa utiliza a geração da EFD - Escrituração Fiscal Digital informe este campo nos casos acima, mesmo que o produto NÃO seja combustível".
  # Tipo: AlphaNum X
  # Tam.: 14
  def e222_icms_st_a_complementar
    return "%014d" % 0
  end

  # 32. ITEM CANCELADO - Este campo será utilizado apenas quando lançamentos de ECF e PDV. Informe "S" se o item do Cupom Fiscal for cancelado, caso contrário informe "N". Para lançamentos diferentes de ECF e PDV informe "N".
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_item_cancelado
    return "N"
  end

  # 33. OPERAÇÕES/PRESTAÇÕES COM MERCADORIAS SUJEITAS AO REGIME DE
  # SUBSTITUIÇÃO TRIBUTÁRIA NAS SAÍDAS - Informe "S" ou "N" se a empresa utiliza máquina registradora/ECF/PDV, se a espécie da nota de saídas (campo 03 deste registro) for ECF, CMR ou PDV, se houver valor no campo Outros de ICMS (campo 23 deste registro ) e se o CFOP (campo 09 deste registro) for um dos abaixo citados. 
  # Não sendo a situação acima ou para notas fiscais de entradas, este campo deve ser preenchido com espaços. 
  # CFOP´s : 5.901, 6.901, 5.902, 6.902, 5.903, 6.903, 5.904, 6.904, 5.905, 6.905, 5.906, 6.906, 5.907, 6.907, 5.908, 6.908, 5.909, 6.909, 5.910, 6.910, 5.911, 6.911, 5.912, 6.912, 5.913, 6.913, 5.914, 6.914, 5.915, 6.915, 5.916, 6.916, 5.917, 6.917, 5.918, 6.918, 5.919, 6.919, 5.920, 6.920, 5.921, 6.921, 5.922, 6.922, 5.923, 6.923, 5.924, 6.924, 5.925, 6.925, 5.926, 5.927, 5.928, 5.929, 6.929, 5.931, 6.931, 5.932, 6.932, 5.949 e 6.949.   
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_op_merc_suj_reg_subst_trib_saida
    return "%-1s" % ""
  end

  # 34. ISS - Este campo será utilizado apenas quando lançamentos de ECF e PDV. Informe "S" se o item do Cupom Fiscal for ISSQN, caso contrário informe "N". Para lançamentos diferentes de ECF e PDV informe "N".
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_iss
    return "N"
  end

  # 35. CÓDIGO UNID. COMERCIAL - Informe o código da unidade de medida utilizada na comercialização do produto/serviço. Esse código deve existir no Cadastro de Unidade de Medidas do sistema, ou no Registro E026. Quando no cadastro do produto/serviço o Tipo for 09-Serviços, preencha este campo com espaços.
  # Tipo: AlphaNum X
  # Tam.: 6
  def e222_codigo_unidade_comercial
    return "%-6s" % "UN"
  end
  
  # 36.CÓDIGO DA NATUREZA DA OPERAÇÃO - Informe o código da natureza da operação quando se tratar de NF modelo 01, 02, 1B, 04 ou 55. Esse código deve existir no Cadastro da Natureza da Operação do sistema, ou no Registro E027.
  # Tipo: AlphaNum X
  # Tam.: 10
  def e222_codigo_natureza_operacao
    return "%-10s" % ""
  end

  # 37. DESCRIÇÃO COMPLEMENTAR DO PRODUTO - Este campo somente deve ser preenchido se a empresa utiliza a geração da EFD-Escrituração Fiscal Digital. 
  # Informe a descrição complementar do produto/serviço quando se tratar de NF modelo 01, 1B, 04 ou 55. 
  # Não sendo as situações acima, preencha este campo com espaços. 
  # Tipo: AlphaNum X
  # Tam.: 50
  def e222_descricao_complementar_do_produto
    return "%-50s" % ""
  end

  # 38. FATOR DE CONVERSÃO - Este campo somente deve ser preenchido se a empresa utiliza a geração da EFD-Escrituração Fiscal Digital. 
  # Informe o fator utilizado para converter (multiplicar) a unidade comercial a ser convertida na unidade adotada no inventário (estoque). 
  # Somente preencha este campo se a informação da unidade de medida comercial for diferente da unidade de medida utilizada no estoque do produto. 
  # Não sendo as situações acima ou quando no cadastro do produto/serviço o Tipo for 09- Serviços, informe zeros neste campo. 
  # Tipo: Num
  # Tam.: 14
  def e222_fator_conversao
    return "%014d" % 0
  end

  # 39. ALÍQUOTA DO ICMS S.T. - Este campo somente deve ser preenchido se a empresa utiliza a geração da EFD-Escrituração Fiscal Digital, caso contrário, informe zeros neste campo. 
  # Informe a Alíquota do ICMS da substituição tributária na unidade da federação de destino quando se tratar de notas fiscais modelo 01, 1B, 04, 06, 28 ou 55.
  # Tipo: Num
  # Tam.: 6
  def e222_aliquota_icms_st
    return "%06d" % 0
  end

  # 40. SIT.TRIB. ICMS TAB. A - Informe o código da Situação Tributária referente ao ICMS conforme Tabela A- Situação Tributária do ICMS.
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_sit_trib_icms_tab_a
    return "%-1s" % "0"
  end
  
  # 41. SIT. TRIB. ICMS TAB. B - Informe o código da Situação Tributária referente ao ICMS conforme Tabela B- Situação Tributária do ICMS.
  # Tipo: AlphaNum
  # Tam.: 2
  def e222_sit_trib_icms_tab_b
    return "%-2s" % "00"
  end

  # 42. SIT. TRIB. IPI - Este campo somente deve ser preenchido se a empresa utiliza a geração da EFD-Escrituração Fiscal Digital. 
  # Informe o Código da Situação Tributária referente ao IPI conforme Tabela da Situação Tributária do IPI, quando se tratar de empresa Indústria e nota fiscal modelo for 01, 1B, 04 e 55. 
  # Não sendo as situações acima ou quando no cadastro do produto/serviço o Tipo for 09- Serviços, preencha este campo com espaços. 
  # Tipo: AlphaNum
  # Tam.: 2
  def e222_sit_trib_ipi
    return "%-2s" % ""
  end

  # 43. APURAÇÃO DISTINTAS DO IPI - Este campo somente deve ser preenchido se a empresa utiliza a geração da EFD-Escrituração Fiscal Digital. 
  # Informe o período de apuração do IPI quando se tratar de empresa Indústria com periodicidade distinta na apuração do IPI e a nota fiscal for modelo 01, 1B, 04 e 55. Se mensal informe "M", se decendial informe "D". 
  # Não sendo as situações acima ou se a empresa não apura IPI ou apura o IPI em uma única apuração, preencha este campo com espaços.
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_apuracao_distintas_do_ipi
    return "%-1s" % ""
  end

  # 44. CÓDIGO DA CONTA - Se a empresa utiliza a geração do arquivo EFD-EscrituraçãoFiscal Digital e o modelo da nota é 01, 1B, 04, 06, 21, 22, 28, 29 e 55, informe o código da conta analítica contábil debitada/creditada do produto/serviço, que deve ser a conta credora ou devedora principal, podendo ser informada a conta sintética (nível acima da conta analítica). 
  # Diferente da situação acima, deixe este campo vazio. 
  # Tipo: AlphaNum X
  # Tam.: 50
  def e222_codigo_da_conta
    return "%-50s" % ""
  end

  # 45. FRETE - Informe o valor do frete do produto.
  # Tipo: Num
  # Tam.: 14
  def e222_frete
    return "%014d" % 0
  end
  
  # 46. FRETE NO TOTAL DA NF - Informe "S" se o valor do frete está incluso no valor total da nota fiscal ou "N" se não está.
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_frete_no_total_da_nf
    return "N"
  end

  # 47. SEGURO - Informe o valor do seguro do produto.
  # Tipo: Num
  # Tam.: 14
  def e222_seguro
    return "%014d" % 0
  end

  # 48. SEGURO NO TOTAL DA NF - Informe "S" se o valor do seguro está incluso no valor total da nota fiscal ou "N" se não está.
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_seguro_no_total_da_nf
    return "N"
  end

  # 49. DESPESAS ACESSÓRIAS - Informe o valor de outras despesas acessórias do produto.
  # Tipo: Num
  # Tam.: 14
  def e222_despesas_acessorias
    return "%014d" % 0
  end

  # 50. DESPESAS ACESSÓRIAS NO TOTAL DA NF - Informe "S" se o valor das despesas acessórias está incluso no valor total da nota fiscal ou "N" se não está.
  # Tipo: AlphaNum
  # Tam.: 1
  def e222_despesas_acessorias_no_total_da_nf
    return "N"
  end
  
  # 51. ACRÉSCIMO - Quando o lançamento for de cupom fiscal com modelos 02 e 2D, informe o valor de acréscimo do produto/serviço, caso contrário, informe zeros.
  # Tipo: Num
  # Tam.: 14
  def e222_acrescimo
    return "%014d" % 0
  end

  # 52. REDUÇÃO BASE CÁLC. ICMS - Informe o percentual de redução da Base de Cálculo do ICMS do produto/serviço, caso contrário, preencher com zeros.
  # Tipo: Num
  # Tam.: 7
  def e222_reducao_base_calculo_icms
    return "%07d" % 0
  end

  # 53. VALOR NÃO TRIBUTADO (RED. DA BC ICMS) - Informe o valor não tributado em função da redução da base de cálculo do ICMS, caso contrário, preencher com zeros. 
  # Este valor será o resultado da diferença entre o valor da Base de Cálculo do ICMS e a Base ICMS Reduzida.
  # Tipo: Num
  # Tam.: 14
  def e222_valor_nao_tributado
    return "%014d" % 0
  end

  # 54. QUANTIDADE CANCELADA - Este campo somente deve ser preenchido se a empresa utiliza a geração da EFD-Escrituração Fiscal Digital e quando for cupom fiscal com modelos 02 e 2D. Informe a quantidade cancelada, no caso de cancelamento parcial de item.
  # Tipo: Num
  # Tam.: 14
  def e222_quantidade_cancelada
    return "%014d" % 0
  end

  # 55. BASE ICMS REDUZIDA - Informe o valor da base de cálculo do ICMS reduzida do produto/serviço, caso contrário, preencher com zeros. 
  # Este valor será conforme o cálculo da Base do ICMS ( x ) % de redução da Base. A Base do ICMS ( - ) o resultado da multiplicação, será o valor da Base de cálculo do ICMS reduzida
  # Tipo: Num
  # Tam.: 14
  def e222_base_icms_reduzida
    return "%014d" % 0
  end

  # 56. DADOS PARA REDEF NF. PAULISTA 
  # Tipo: Num
  # Tam.: 1
  def e222_dados_para_redef_nf_paulista
    return "%1d" % 1
  end

  # 57. NUMERO DO TOTALIZADOR
  # Tipo: AlphaNum
  # Tam.: 2
  def e222_numero_do_totalizador
    return "%-2s" % ""
  end

  # 58. CONTROLE DO SISTEMA
  # Tipo: Num
  # Tam.: 1
  def e222_controle_do_sistema
    return "0"
  end

end
