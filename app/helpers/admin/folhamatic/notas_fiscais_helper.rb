module Admin::Folhamatic::NotasFiscaisHelper
  
  # E200- NOTAS FISCAIS
  # Este registro importará informações referente ao cabeçalho da nota fiscal para o Menu Movimentos, item NF Entradas e Saídas. 
  # Sempre que gerar um registro E200 gerar também um registro filho E201-LANÇAMENTOS DE IMPOSTOS DAS NOTAS FISCAIS. 
  # A ordenação no aquivo para cada nota será o registro E200 (pai) e em seguida o(s) registro(s) E201 (filho). 
  # OBS: Poderá existir apenas um registro E200 por nota fiscal. 
  # Quando for necessário importar uma nota/cupom fiscal em que já exista cadastrado no sistema a mesma numeração inicial, será necessário alterar a chave da nota. 
  # Quando for um cupom fiscal, para que o mesmo seja importado, cadastre um novo Código (Série) no menu Arquivos-Máquina Registradora-Dados da Máquina Registradora/ECF/PDV e utilize este código como Série no lançamento. 
  # Quando for uma nota fiscal, modifique algum campo que faz parte da chave da nota para que a mesma possa ser importada, como por exemplo incluindo um ponto no campo 03-ESPÉCIE DA NOTA. 
  def e200_notas_ficais(pedido)
    return (e200_nome_do_registro +
            e200_entradas_saidas +
            e200_especie_nf +
            e200_serie_nf +
            e200_subserie_nf +
            e200_numero_inicial_nf(pedido) +
            e200_numero_final_nf(pedido) +
            e200_codigo_cliente(pedido) +
            e200_data_de_emissao(pedido) +
            e200_data_de_saida(pedido) +
            e200_uf_nf(pedido) +
            e200_modelo_nf +
            e200_emitente_nf +
            e200_situacao_nf +
            e200_justificativa_nf_cancelada +
            e200_hora_emissao_nf(pedido) +
            e200_hora_saida_nf(pedido) +
            e200_tipo_do_frete +
            e200_valor_contabil(pedido) +
            e200_cod_int_contabil_impostos_retidos +
            e200_codigo_da_conta +
            e200_numero_linhas_lancamento
           )
  end
  
  # 1. NOME DO REGISTRO - Informe E200
  # Tipo: AlphaNum
  # Tam.: 4
  def e200_nome_do_registro
    return "E200"
  end
  
  # 2. ENTRADAS OU SAÍDAS - Informe "E" para nota fiscal de entrada ou "S" para nota fiscal de saída.
  # Tipo: AlphaNum
  # Tam.: 1
  def e200_entradas_saidas
    return "S"
  end
  
  # 3. ESPÉCIE N.F. - Informe a espécie da nota fiscal.
  # Tipo: AlphaNum X
  # Tam.: 5
  def e200_especie_nf
    return "%-5s" % "NF"
  end
  
  # 4. SÉRIE N.F. - Informe a série da nota fiscal conforme Tabela de Orientações de Séries e
  # Subséries. Quando se tratar de cupom fiscal informe a série conforme o campo Código
  # (Série) do cadastro dos Dados da Máquina Registradora/ECF/PDV contido no Sistema EFiscal (menu Arquivos).
  # Tipo: AlphaNum X
  # Tam.: 3
  def e200_serie_nf
    return "%-3s" % "2"
  end
  
  # 5. SUBSÉRIE N.F - Informe a subsérie da nota fiscal conforme Tabela de Orientações de
  # Séries e Subséries. Quando se tratar de cupom fiscal, deixe este campo vazio.
  # Tipo: AlphaNum X
  # Tam.: 2
  def e200_subserie_nf
    return "%-2s" % ""
  end
  
  # 6. Nº INICIAL DA N. F. - Informe o número da nota fiscal. Caso esteja lançando nota fiscal de
  # saídas com várias notas agrupadas (ex. série D..), informe o número da primeira nota fiscal.
  # Campo Obrigatório.
  # Tipo: Num 
  # Tam.: 10
  def e200_numero_inicial_nf(pedido)
    return "%010d" % pedido.nota_fiscal.to_i
  end

  # 7. Nº FINAL DA N. F - Caso esteja lançando nota fiscal de saídas com várias notas agrupadas
  # (ex. série D..), informe o número da última nota fiscal, caso contrário, repetir o número da nota fiscal informada no campo 06. 
  # Este campo somente será utilizado nas notas fiscais de saídas, quando tratar de nota fiscal de entradas, informar zeros.
  # Tipo: Num
  # Tam.: 10
  def e200_numero_final_nf(pedido)
    return "%010d" % pedido.nota_fiscal.to_i
  end

  # 8. CÓDIGO DO CLIENTE/FORNECEDOR - Informe o código do cliente ou fornecedor da nota fiscal conforme cadastro de clientes e fornecedores. 
  # Campo obrigatório para notas fiscais de entradas. 
  # OBS: Este campo só poderá estar vazio nas notas de saídas quando se tratar de venda a consumidor (NF série D..), ou quando cupom fiscal (NF espécie ECF, CMR e PDV), diferente
  # disso, o campo deverá ser informado para não ocorrer rejeição na validação de arquivos magnéticos como SINTEGRA, GRF-CBT, SINCO, EFD e outros.
  # Tipo: AlphaNum X
  # Tam.: 20
  def e200_codigo_cliente(pedido)
    if registrar_cliente?(pedido)
      return "%-20s" % codigo_cliente(pedido)
    else
      return "%-20s" % "19878" # 19878 = cliente padrao do escritorio do ARI
    end
  end

  # DATA DE EMISSÃO - Informe a data de emissão da nota fiscal no formato AAAAMMDD.
  # Tipo: Data
  # Tam.: 8
  def e200_data_de_emissao(pedido)
    if pedido.data_nf
      data = pedido.data_nf.strftime("%Y%m%d")
    elsif pedido.data_envio
      data = pedido.data_envio.strftime("%Y%m%d")
    else
      data = (pedido.created_at + 7.days).strftime("%Y%m%d")
    end
    return data
  end

  # DATA DE ENTRADA/SAÍDA - Informe a data da entrada ou saída da nota fiscal na empresa no formato AAAAMMDD. 
  # A importação sempre utilizará este campo como referência para exibição das notas de acordo com o mês/ano ativo no sistema. 
  # Ex: se foi informado no campo 09 a data 31/01/2009 e neste campo a data 01/02/2009, então ao importar o sistema demonstrará a nota no mês 02/2009.
  # Tipo: Data
  # Tam.: 8
  def e200_data_de_saida(pedido)
    if pedido.data_nf
      data = pedido.data_nf.strftime("%Y%m%d")
    elsif pedido.data_envio
      data = pedido.data_envio.strftime("%Y%m%d")
    else
      data = (pedido.created_at + 7.days).strftime("%Y%m%d")
    end
    return data
  end

  # UF DA N.F. - Informe o estado (UF) constante na nota fiscal. 
  # Atenção: Para notas fiscais de Exportação informar EX e de Importação informar IM.
  # Tipo: AlphaNum
  # Tam.: 2
  def e200_uf_nf(pedido)
    return "%-2s" % pedido.entrega_estado
  end

  # MODELO DA N.F. - Informe o modelo da nota fiscal conforme Tabela de Modelos de Documentos Fiscais. 
  # Campo obrigatório.
  # Tipo: AlphaNum
  # Tam.: 2
  def e200_modelo_nf
    return "%-2s" % "01"
  end

  # EMITENTE DA N.F.: Para notas de saídas informe sempre "P" (emissão própria), 
  # e para notas de entradas informe "T" (emissão de terceiros) se a nota que está sendo lançada foi emitida por terceiros, ou seja, a nota foi recebida de outra empresa, ou "P" se a emissão foi feita pela empresa que está importando as notas fiscais (ex. por compras feitas de pessoas físicas, produtor rural, etc, os quais não possuem nota fiscal própria, e então a empresa que adquire os produtos, emite a nota para fazer o lançamento de entradas). 
  # Campo obrigatório.
  # Tipo: AlphaNum
  # Tam.: 1
  def e200_emitente_nf
    return "P"
  end

  # SITUAÇÃO DA N.F. - Informe a situação da nota fiscal conforme abaixo: 
  # 00 - Regular 
  # 01 - Extemporâneo 
  # 02 - Cancelado 
  # 03 - Cancelado Extemporâneo 
  # 04 - NF-e ou CT-e denegada 
  # 05 - NF-e ou CT-e inutilizada 
  # 06 - Complementar 
  # 07 - Complementar Extemporâneo 
  # 08 - Regime Especial/Norma Específica 
  # OBS: Mesmo que a situação seja de cancelamento ou complemento, deve ser gerado também o registro filho E201 informando até o CFOP campo 08 e o campo 27, demais campos que se refere a valores deixar zerado.
  # Tipo: Num
  # Tam.: 2
  def e200_situacao_nf
    return "00"
  end

  # JUSTIFICATIVA NF CANCELADA - Se a empresa utiliza a geração do arquivo REDF-Nota Fiscal Paulista e a situação da NF de saída (campo 14) é Cancelado ou Cancelado Extemporâneo, informe a justificativa do cancelamento da nota fiscal. 
  # Diferente da situação acima deixe este campo vazio. 
  # OBS: A justificativa deverá conter no mínimo 15 caracteres, para que o Programa da Secretaria da Fazenda, valide o arquivo corretamente, caso contrário, o mesmo será rejeitado.
  # Tipo: AlphaNum X
  # Tam.: 254
  def e200_justificativa_nf_cancelada
    return "%-254s" % ""
  end

  # HORA DA EMISSÃO DA N.F. (REDF) - Se a empresa utiliza a geração do arquivo REDFNota Fiscal Paulista, informe a hora, minuto e segundo da emissão da nota fiscal.(formato HHMMSS)
  # Tipo: Num
  # Tam.: 6
  def e200_hora_emissao_nf(pedido)
    if pedido.data_nf
      hora = pedido.data_nf.strftime("%H")
    elsif pedido.data_envio
      hora = pedido.data_envio.strftime("%H")
    else
      hora = (pedido.created_at + 7.days).strftime("%H")
    end
    return hora + "0000"
  end

  # HORA DA ENTRADA/SAÍDA DA N.F. (REDF) - Se a empresa utiliza a geração do arquivo REDF-Nota Fiscal Paulista, informe a hora, minuto e segundo da entrada ou saída da mercadoria/produto/serviço da nota. (formato HHMMSS).
  # Tipo: Num
  # Tam.: 6
  def e200_hora_saida_nf(pedido)
    if pedido.data_nf
      hora = pedido.data_nf.strftime("%H%M%S")
    elsif pedido.data_envio
      hora = pedido.data_envio.strftime("%H%M%S")
    else
      hora = (pedido.created_at + 7.days).strftime("%H%M%S")
    end
    return hora
  end

  # TIPO DO FRETE - "Preencher com "1" caso o frete tenha sido pago pelo Emitente (CIF), 
  # com "2" caso tenha sido pago pelo Destinatário (FOB) ou 
  # com "3" se o frete foi pago por terceiros. 
  # Preencher com zero quando for lançamento de CMR, ECF ou PDV, ou caso não haja na nota fiscal informação do pagamento do frete (Ex. remessas simbólicas, faturamento simbólico, transporte próprio, venda balcão), diferente disso, para fins de geração do arquivo de combustíveis (GRF-CBT), SINTEGRA, SINCO e EFD, esta informação será necessária. 
  # Para fins da EFD é orientado que quando houver transporte com mais de um responsável pelo seu pagamento, deve ser informado o indicador do frete relativo ao responsável pelo primeiro percurso.
  # Tipo: Num
  # Tam.: 1
  def e200_tipo_do_frete
    return "2"
  end

  # VALOR CONTÁBIL - Informe o valor total da nota fiscal. (Valor Contábil).
  # Tipo: Num
  # Tam.: 14
  def e200_valor_contabil(pedido)
    # TOTAL DA NOTA!
    preco_sem_ponto = sprintf("%.2f", pedido.total_sem_frete_sem_desconto).delete(".").to_i
    return "%014d" % preco_sem_ponto
  end

  # CÓD. INT. CONTÁBIL IMPOSTOS RETIDOS- Informe o número do código de integração se a empresa exporta os impostos retidos das notas fiscais de saídas para a contabilidade do Sistema Telecont, caso contrário, deixe este campo vazio. 
  # Este código equivale aos impostos PIS, COFINS e CSLL retidos do registro E209 e ao IRRF do registro E210.
  # Tipo: AlphaNum
  # Tam.: 2
  def e200_cod_int_contabil_impostos_retidos
    return "%-2s" % ""
  end

  # CÓDIGO DA CONTA - Se a empresa utiliza a geração do arquivo EFD-Escrituração Fiscal Digital e o modelo da nota é 02, 07, 08, 8B, 09, 10, 11, 18, 21, 22, 26, 27 ou 57, informe o código da conta analítica contábil debitada/creditada, que deve ser a conta credora ou devedora principal, podendo ser informada a conta sintética (nível acima da conta analítica). 
  # Diferente da situação acima, deixe este campo vazio.
  # Tipo: AlphaNum X
  # Tam.: 50
  def e200_codigo_da_conta
    return "%-50s" % ""
  end

  # Nº LINHAS DE LANÇAMENTO - Informe o número total de linhas de lançamento de ICMS/IPI que a nota fiscal contém.
  # Este total de linhas se refere a quantidade de registros E201 que a nota tem, por exemplo uma N.F. que tem duas alíquotas de ICMS 18% e 25% terá duas linhas com registro E201, então neste campo deverá constar 02. 
  # Este número total pode ser identificado através do campo 27 do último registro E201 da nota.
  # Tipo: Num
  # Tam.: 2
  def e200_numero_linhas_lancamento
    return "%02d" % 1
  end

end