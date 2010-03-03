module Admin::Folhamatic::ImpostosDasNotasHelper
  
  # E201 LANÇAMENTOS DE IMPOSTOS DAS NOTAS FISCAIS
  # Este registro importará informações referente os lançamentos de impostos da nota fiscal e serão importadas para as linhas de lançamento da nota (Menu Movimentos, item NF Entradas e Saídas). 
  # Sempre que gerar um registro E201 gerar também um registro pai E200-NOTAS FISCAIS. 
  # Após importado, a ordem das linhas de lançamento da nota, serão apresentadas no sistema conforme a definição do campo 27 deste registro E201 no arquivo. 
  # OBS: Poderão existir vários registros E201 por nota fiscal.
  def e201_lancamentos_de_impostos_das_notas_fiscais(pedido)
    return (e201_nome_do_registro +
            e201_saidas +
            e201_especie_nf +
            e201_serie_nf +
            e201_subserie_nf +
            e201_numero_nf(pedido) +
            e201_codigo_cliente(pedido) +
            e201_cfop(pedido) +
            e201_cod_integracao +
            e201_tipo_pagamento +
            e201_bc_icms(pedido) +
            e201_codigo_turbo +
            e201_reducao_base_calculo_icms +
            e201_aliquota_icms +
            e201_valor_do_icms(pedido) +
            e201_isento_de_icms(pedido) +
            e201_outras_de_icms(pedido) +
            e201_icms_subst_trib +
            e201_base_subst_trib +
            e201_bc_ipi +
            e201_codigo_turbo_ipi +
            e201_valor_ipi +
            e201_isentos_de_ipi +
            e201_outras_de_ipi +
            e201_contribuinte_do_icms +
            e201_observacao_da_linha_de_lancamento(pedido) +
            e201_numero_sequencial_do_lancamento +
            e201_tipo_de_antecipacao_tribut +
            e201_anulacao_servico_transporte +
            e201_apuracoes_distintas_ipi +
            e201_valor_deduzido_na_bc_pis_cofins +
            e201_excluidas_rs +
            e201_venda_para_entrega_futura +
            e201_operacao_com_mercadoria_suj_reg_subs_trib_saida +
            e201_numero_do_totalizador +
            e201_sit_trib_imcs_tab_a +
            e201_sit_trib_imcs_tab_b +
            e201_sit_trib_ipi_ctipi +
            e201_controle_do_sistema
          )
  end
  
  # 1. NOME DO REGISTRO - Informe E201
  # Tipo: AlphaNum
  # Tam.: 4
  def e201_nome_do_registro
    return "E201"
  end

  # 2. ENTRADAS OU SAÍDAS - Informe "E" para nota fiscal de entrada ou "S" para nota fiscal de saída.
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_saidas
    return "S"
  end

  # 3. ESPÉCIE N.F. - Informe a espécie da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 5
  def e201_especie_nf
    return "%-5s" % "NF"
  end

  # 4. SÉRIE N.F - Informe a série da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 3
  def e201_serie_nf
    return "%-3s" % "2"
  end
  
  # 5. SUBSÉRIE N.F - Informe a subsérie da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 2
  def e201_subserie_nf
    return "%-2s" % ""
  end
  
  # 6. NÚMERO N.F. - Informe o número da nota fiscal. 
  # No caso de notas fiscais de saídas agrupadas, informar o número inicial.
  # Tipo: Num
  # Tam.: 10
  def e201_numero_nf(pedido)
    return "%010d" % pedido.nota_fiscal.to_i
  end
  
  # 7. CÓDIGO DO CLIENTE/FORNECEDOR - Informe o código do cliente ou fornecedor da nota fiscal conforme cadastro de clientes e fornecedores.
  # Tipo: AlphaNum X
  # Tam.: 20
  def e201_codigo_cliente(pedido)
    if registrar_cliente?(pedido)
      return "%-20s" % codigo_cliente(pedido)
    else
      return "%-20s" % "19878" # 19878 = cliente padrao do escritorio do ARI
    end
  end
  
  # CFOP - Informe o CFOP constante na nota fiscal. Campo obrigatório.
  # Tipo: Num
  # Tam.: 4
  def e201_cfop(pedido)
    if (pedido.entrega_estado == "SP")
      return "%04d" % 5102
    else
      return "%04d" % 6102
    end
  end
  
  # C.I. - Informe o número do código de integração (C.I.) se a empresa exporta dados para a contabilidade do Sistema Telecont, caso contrário, deixe este campo vazio.
  # Tipo: AlphaNum
  # Tam.: 2
  def e201_cod_integracao
    return "%-2s" % ""
  end
  
  # TIPO DE PAGAMENTO - Informe "1" para compra/venda á vista ou 
  #                         com "2" para compra/venda á prazo. 
  # Quando não houver pagamento, informe "0" (zero).
  # Tipo: Num
  # Tam.: 1
  def e201_tipo_pagamento
    return "1"
  end
  
  # 11. BC ICMS - Informe a Base de Cálculo do ICMS da linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_bc_icms(pedido)
    #preco_sem_ponto = sprintf("%.2f", pedido.produtos_quantidades[0].nf_valortotal).delete(".").to_i
    return "%014d" % 0
  end
  
  # CÓDIGO TURBO - Este campo é para informação dos códigos turbos utilizado em alguns tipos de operações e para cálculos automáticos no Sistema E-Fiscal; classificar conforme Tabela de Códigos Turbo. 
  # OBS: Estes códigos turbos fazem o cálculo automático apenas nos lançamentos efetuados dentro do sistema, já na importação, os valores devem ser informados nos seus respectivos campos. 
  # Não utilizar o código turbo 506, se a empresa estiver enquadrada no Simples Nacional (campo IRPJ do cadastro da empresa como Simples ou EPP Simples).
  # Tipo: Num
  # Tam.: 3
  def e201_codigo_turbo
    return "%03d" % 0
  end
  
  # REDUÇÃO BASE CÁLC. ICMS - Se utilizado o código turbo 520 
  # - Outras Reduções ou 523 - Diferimento Parcial - RS (este para notas de saídas de empresas do Estado do Rio Grande do Sul), 
  # informe o percentual de redução da Base de Cálculo do ICMS da linha de lançamento, sendo que para o código turbo 520 é obrigatório o preenchendo com zero na última casa decimal.
  # Caso não foi utilizado nenhum destes códigos, preencher com zeros.
  # Tipo: Num
  # Tam.: 6
  def e201_reducao_base_calculo_icms
    return "%06d" % 0
  end
  
  # ALÍQUOTA DO ICMS - Informe a alíquota do ICMS da linha de lançamento. 
  # Exemplo: alíquota de 18% informar no arquivo 0180000.
  # Tipo: Num
  # Tam.: 7
  def e201_aliquota_icms
    return "%07d" % 0
  end
  
  # VALOR DO ICMS - Informe o valor do ICMS da linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_valor_do_icms(pedido)
    return "%014d" % 0
  end
  
  # ISENTOS DE ICMS - Informe o valor isento de ICMS da linha de lançamento. 
  # Para notas de entradas de empresas situadas em estados diferentes de AM, MG e PR, que tenha informação de Isentos de ICMS e Outros de ICMS, é aconselhável gerar um registro E201 para cada valor, pois, para impressão correta do Livro de Entradas em modo gráfico, não pode haver lançamentos de Isentos ICMS e Outros ICMS na mesma linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_isento_de_icms(pedido)
    return "%014d" % 0
  end
  
  # OUTRAS DE ICMS - Informe o valor de outras de ICMS da linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_outras_de_icms(pedido)
    # TOTAL DA NOTA!
    preco_sem_ponto = sprintf("%.2f", pedido.total_sem_frete_sem_desconto).delete(".").to_i
    return "%014d" % preco_sem_ponto
  end
  
  # ICMS SUBST. TRIB. - Informe o valor do ICMS Substituição Tributária da linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_icms_subst_trib
    return "%014d" % 0
  end
  
  # BASE SUBST. TRIB. - Informe a Base de Substituição Tributária da linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_base_subst_trib
    return "%014d" % 0
  end
  
  # BC IPI - Informe a Base de Cálculo do IPI da linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_bc_ipi
    return "%014d" % 0
  end
  
  # CÓDIGO TURBO P/ IPI - Informe "0" quando a alíquota do IPI for zero. Se a empresa for Simples Nacional e houver notas de saídas com IPI Substituição Tributária, informe "4". 
  # Não sendo nenhuma das situações acima, deixe este campo vazio.
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_codigo_turbo_ipi
    return "%1s" % ""
  end
  
  # VALOR DO IPI - Informe o valor do IPI da linha de lançamento. 
  # Preencher a 1ª posição deste campo com o sinal de negativo quando houver a situação de IPI não aproveitável.
  # Tipo: Num
  # Tam.: 14
  def e201_valor_ipi
    return "%014d" % 0
  end
  
  # ISENTOS DE IPI - Informe o valor isento de IPI da linha de lançamento. 
  # Para notas de entradas de empresas indústrias situadas em estados diferentes de AM, MG e PR, que tenha informação de Isentos de IPI e Outros de IPI, é aconselhável gerar um registro E201 para cada valor, pois, para impressão correta do Livro de Entradas em modo gráfico, não pode haver lançamentos de Isentos IPI e Outros IPI na mesma linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_isentos_de_ipi
    return "%014d" % 0
  end
  
  # OUTRAS DE IPI - Informe o valor de outras de IPI da linha de lançamento.
  # Tipo: Num
  # Tam.: 14
  def e201_outras_de_ipi
    return "%014d" % 0
  end
  
  # CONTRIBUINTE DO ICMS - Este campo é utlizado somente para notas fiscais de saída.
  # Preencher com "S" caso a venda seja para contribuinte do ICMS ou "N" quando venda para não contribuinte do ICMS. 
  # Quando for nota de entrada preencher este campo com "S".
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_contribuinte_do_icms
    return "N"
  end
  
  # OBSERVAÇÃO DA LINHA DE LANÇAMENTO - Este campo é para observações diversas da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 30
  def e201_observacao_da_linha_de_lancamento(pedido)
    return "%-30s" % "" #PedidoID: #{pedido.id} / deixar em branco
  end
  
  # Nº SEQUENCIAL DO LANÇAMENTO - Informe o número sequencial de ordem da linha de lançamento. 
  # Esse número de linhas refere-se a quantidade de linhas que a nota tem, por exemplo uma NF que tem dois CFOP´s, neste caso haverá dois registros E201, especificando um CFOP com nº sequencial como 01 e o outro CFOP com nº sequencial como 02.
  # Tipo: Num
  # Tam.: 2
  def e201_numero_sequencial_do_lancamento
    return "%02d" % 1
  end
  
  # TIPO DE ANTECIPAÇÃO TRIBUTÁRIA - Caso a nota contenha valor de ICMS Substituição Tributária (campo 18), informe o tipo de antecipação tributária conforme tabela abaixo: 
  # 0 - Substituição tributária informada pelo substituto ou pelo substituído que não incorra em nenhuma das situações anteriores. 
  # 1 - Pagamento de substituição efetuada pelo destinatário, quando não efetuada ou efetuada a menor pelo substituto 
  # 2 - Antecipação tributária efetuada pelo destinatário apenas com complementação do diferencial de alíquota 
  # 3 - Antecipação tributária com MVA(Margem de Valor Agregado), efetuada pelo destinatário sem encerrar a fase de tributação 
  # 4 - Antecipação tributária com MVA(Margem de Valor Agregado), efetuada pelo destinatário encerrando a fase de tributação 
  # 5 - Substituição Tributária interna motivada por regime especial de tributação. 
  # 6 - ICMS pago na importação. 
  # Campo obrigatório para a situação acima. Não existindo esta situação, deixe este campo vazio. 
  # OBS: Quando a nota possuir vários registros E201 com valor de ICMS Subst. Tribut., repita em todos os registros o mesmo código. Se for informado códigos diferentes para uma mesma nota, será considerado o código informado no último registro.
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_tipo_de_antecipacao_tribut
    return "%1s" % ""
  end
  
  # ANULAÇÃO DE SERVIÇO DE TRANSPORTE - Informe "C" caso seja Transporte de Cargas ou "P" Transporte de Pessoas. 
  # Campo obrigatório quando nota de Anulação de valor de Serviço de transporte.. 
  # Não existindo a situação acima, deixe este campo vazio. 
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_anulacao_servico_transporte
    return "%1s" % ""
  end
  
  # APURAÇÕES DISTINTAS DO IPI - Se a empresa apura IPI com apurações distintas, informe o tipo de apuração, sendo "M" para apuração Mensal e "D" para apuração Decendial. 
  # Para IPI com apurações distintas, estando este campo vazio, o valor do IPI não entrará na apuração do IPI. 
  # Deixe este campo vazio se a empresa não apura IPI, ou apura o IPI em uma única apuração.
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_apuracoes_distintas_ipi
    return "%1s" % ""
  end
  
  # VALOR A SER DEDUZIDO DA BASE DE CÁLC. PIS/COFINS (NF ENTRADAS) - 
  # Este campo deve ser utilizado por empresas que necessitam fazer a dedução na base de cálculo do PIS e COFINS através das notas de entradas pelo fato de utilizarem ECF nas vendas. 
  # Não existindo esta informação, este campo deve ser preenchido com zeros.
  # Tipo: Num
  # Tam.: 14
  def e201_valor_deduzido_na_bc_pis_cofins
    return "%014d" % 0
  end
  
  # EXCLUÍDAS (RS) - Este campo deverá ser utilizado por empresas situadas no estado do Rio Grande do Sul para informar as importâncias excluídas do valor adicionado nas notas de entradas e saídas. Este campo será utilizado na geração da GIA Modelo B (TR 950 - Anexo 5 - Entradas e Saídas). 
  # Não existindo esta informação, este campo deve ser preenchido com zeros.
  # Tipo: Num
  # Tam.: 14
  def e201_excluidas_rs
    return "%014d" % 0
  end
  
  # VENDA P/ ENTREGA FUTURA - Informe "S" se deseja que o valor desta linha de lançamento entre no Faturamento, 
  # caso contrário informe "N". 
  # Sendo uma das situações abaixo, informe "S" 
  # - Quando se tratar de nota fiscal de entrada 
  # - Quando a informação do campo 08 (CFOP) for diferente de 5.922, 6.922, 5.116, 6.116, 5.117, 6.117, 5.651, 6.651, 5.652, 6.652, 5.653, 6.653, 5.654, 6.654, 5.655, 6.655 5.656, 6.656. 
  # - Quando a empresa for Posto de Gasolina (campo Subtipo do cadastro da empresa) e a informação do campo 08 (CFOP) for 5.651, 6.651, 5.652, 6.652, 5.653, 6.653, 5.654, 6.654, 5.655, 6.655 5.656, 6.656. 
  # OBS: Caso seja utilizado algum código turbo (campo 12), os cálculos referente ao código utilizado, serão feitos pelo sistema independente da resposta deste campo.
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_venda_para_entrega_futura
    return "%-1s" % "S"
  end
  
  # OPERAÇÕES/PRESTAÇÕES COM MERCADORIAS SUJEITAS AO REGIME DE SUBSTITUIÇÃO TRIBUTÁRIA NAS SAÍDAS 
  # - Informe "S" ou "N" se a empresa utiliza máquina registradora/ECF/PDV, se a espécie da nota de saídas (campo 03 deste registro) for
  # ECF, CMR ou PDV, se houver valor no campo Outras de ICMS (campo 17 deste registro ) e se o CFOP (campo 08 deste registro) for um dos abaixo citados. 
  # Não sendo a situação acima ou para notas fiscais de entradas, deixe este campo vazio. 
  # CFOP´s : 5.901, 6.901, 5.902, 6.902, 5.903, 6.903, 5.904, 6.904, 5.905, 6.905, 5.906, 6.906,
  # 5.907, 6.907, 5.908, 6.908, 5.909, 6.909, 5.910, 6.910, 5.911, 6.911, 5.912, 6.912, 5.913,
  # 6.913, 5.914, 6.914, 5.915, 6.915, 5.916, 6.916, 5.917, 6.917, 5.918, 6.918, 5.919, 6.919,
  # 5.920, 6.920, 5.921, 6.921, 5.922, 6.922, 5.923, 6.923, 5.924, 6.924, 5.925, 6.925, 5.926,
  # 5.927, 5.928, 5.929, 6.929, 5.931, 6.931, 5.932, 6.932, 5.949 e 6.949.
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_operacao_com_mercadoria_suj_reg_subs_trib_saida
    return "%-1s" % ""
  end
  
  # NÚMERO DO TOTALIZADOR - Se a empresa utiliza a geração do arquivo EFD-Escrituração Fiscal, preencha este campo quando se tratar de NF de Saídas, espécie ECF, CMR e PDV,
  # modelo 2, 2D, 2E, 13, 14, 15 e 16 se para a máquina que está sendo gerado o lançamento existe mais que um totalizador com a situação Tributado ICMS referente a alíquota informada no campo 14. 
  # Não existindo a situação acima, deixe este campo vazio.
  # Tipo: AlphaNum
  # Tam.: 2
  def e201_numero_do_totalizador
    return "%-2s" % ""
  end
  
  # SIT.TRIB. ICMS - TAB. A - Se a empresa utiliza a geração do arquivo EFD-Escrituração Fiscal, para NF modelo 07, 08, 8B, 09, 10, 11, 26, 27 e 57, informe o código da Situação Tributária referente ao ICMS conforme Tabela A- Situação Tributária do ICMS. 
  # Campo obrigatório para a situação acima. Não existindo esta situação, deixe este campo vazio.
  # Tipo: AlphaNum
  # Tam.: 1
  def e201_sit_trib_imcs_tab_a
    return "%-1s" % ""
  end
  
  # SIT. TRIB. ICMS - TAB. B - Se a empresa utiliza a geração do arquivo EFD-Escrituração Fiscal, para NF modelo 07, 08, 8B, 09, 10, 11, 26, 27 e 57, informe o código da Situação Tributária referente ao ICMS conforme Tabela B- Situação Tributária do ICMS. 
  # Campo obrigatório para a situação acima. Não existindo esta situação, deixe este campo vazio. 
  # Tipo: AlphaNum
  # Tam.: 2
  def e201_sit_trib_imcs_tab_b
    return "%-2s" % ""
  end
  
  # SIT. TRIB. IPI - CTIPI - Se a empresa utiliza a geração do arquivo EFD-Escrituração Fiscal e for Indústria com apuração de IPI Mensal ou Decendial ou distinta = Mensal/Decendial, informe o Código da Situação Tributária referente ao IPI conforme Tabela - Situação Tributária do IPI. 
  # Campo obrigatório para a situação acima. Não existindo esta situação, deixe este campo vazio. 
  # Tipo: AlphaNum
  # Tam.: 2
  def e201_sit_trib_ipi_ctipi
    return "%-2s" % ""
  end
  
  # CONTROLE DO SISTEMA - Informe "0" (zero) para controle interno do Sistema E-Fiscal.
  # Tipo: Num
  # Tam.: 1
  def e201_controle_do_sistema
    return "0"
  end
  
end