module AdminHelper
  
  def descreve_comprador(pedido, options = {})
    str = "#{pedido.pessoa.nome}<br />"
    str += "#{mail_to(pedido.pessoa.email)}<br />"
    str += formata_cpf(pedido.pessoa.cpf)
    if pedido.processando_envio? or pedido.processando_envio_envelopado?
      str += "<br />"
      str += link_to('imprimir nota fiscal', 
                    { :action => 'print', 
                      :id => pedido.id,
                      :nota_fiscal => 1 }, 
                      :class => 'etiqueta', 
                      :popup => ["status=1,toolbar=0,location=0,menubar=1,resizable=1,width=800,height=650"])
    elsif pedido.processando_envio_notafiscal? or pedido.produto_enviado? or pedido.produto_enviado_cod_postagem? or pedido.recebido_pelo_cliente? or pedido.encerrado?
      str += "<br />"
      str += "NF: <b>#{pedido.nota_fiscal}</b>"
    end
    return str
  end
  
  def descreve_status(pedido, options = {})
    case pedido.status
      when 'aguardando_pagamento'
        style_str = "color:#0ae"
      when /(processando_envio)\w*/
        style_str = "color:#f33;font-weight:bold;"
      when /(produto_enviado)\w*/
        style_str = "color:#51CC35;font-weight:bold;"
      when 'recebido_pelo_cliente', 'encerrado'
        style_str = "color:#282;"
      else
        style_str = "color:#999"
    end
    str = content_tag(:span, pedido.status.humanize, :style => style_str)
    str = content_tag(:b, str) if str.include?('Processando')
    
    if (pedido.retornos_pgmtos.size > 0)
      str += "<br />Retornos Auto: "  
      links = []
      pedido.retornos_pgmtos.each_with_index do |retorno, i|
        links << link_to_remote( i+1, { :url => { 
                                          :action => "retorno_pgmto", 
                                          :rid => retorno.id 
                                        },
                                        :update => "retorno_#{retorno.id}",
                                        :position => :after,
                                        :complete => visual_effect(:pulsate, "retorno_infos_#{retorno.id}", :pulses => 4, :duration => 1.5)
                                       },
                                       :id => "retorno_#{retorno.id}")
      end
      str += links.join(", ")
    end
    return str
  end
  
  def descreve_produtos_pedido(pedido, my_options = {})
    options = {
      :com_preco_unitario => false,
      :com_valor_total => false
    }
    options = options.merge!(my_options)
    str = ""
    pedido.produtos_quantidades.each do |pq|
      str += "<p class=\"item_produto\"><b>#{pq.qtd}</b> #{pq.produto.descricao_simples} "
      str += image_tag("icones/para_presente.gif") if pq.presente
      str += "<span class=\"preco_unitario\">#{number2currency(pq.preco_unitario)}/unid.</span>" if options[:com_preco_unitario]
      str += "<span class=\"valor_total\">#{number2currency(pq.qtd * pq.preco_unitario)}</span>" if options[:com_valor_total]
      str += "</p>"
    end
    return str
  end
  
  # Retorna <tr>...</tr> com os dados dos produtos do pedido
  def descreve_produtos_pedido_em_tabela(pedido, my_options = {})
    options = {
      :com_preco_unitario => false,
      :com_valor_total => false
    }
    options = options.merge!(my_options)
    str = ""
    pedido.produtos_quantidades.each do |pq|
      str += "<tr>"
      str += "  <td class=\"quantidade\">#{pq.qtd}</td>"
      str += "  <td class=\"descricao\">#{pq.produto.descricao_simples}</td>"
      str += "  <td class=\"presente\">"
      str += image_tag('icones/para_presente.gif') if pq.presente
      str += "  </td>"
      str += "  <td class=\"preco_unitario\">#{number2currency(pq.preco_unitario)}/unid.</td>" if options[:com_preco_unitario]
      str += "  <td class=\"valor_total\">#{number2currency(pq.qtd * pq.preco_unitario)}</td>" if options[:com_valor_total]
      str += "</tr>"
    end
    return str
  end
  
  def descreve_entrega(pedido, options = {})
    tmp  = ""
    tmp += "<span class=\"para_nome\">"
    tmp += pedido.para
    tmp += "</span><br />"
    tmp += "#{pedido.entrega_endereco}"
    tmp += ", #{pedido.entrega_numero}" if pedido.entrega_numero
    tmp += " #{pedido.entrega_complemento}" if pedido.entrega_complemento
    tmp += "<br />"
    tmp += "#{pedido.entrega_bairro}<br />" if pedido.entrega_bairro
    tmp += "#{pedido.cep} - #{pedido.entrega_cidade} - #{pedido.entrega_estado}"
    tmp += link_to('imprimir envelope', 
                  { :action => 'print', 
                    :id => pedido.id }, 
                    :class => 'etiqueta', 
                    :popup => ["status=1,toolbar=0,location=0,menubar=1,resizable=1,width=800,height=650"]) if pedido.processando_envio? or pedido.processando_envio_envelopado?
    return tmp
  end
  
  def calcula_total_pedido(pedido)
    t = 0
    pedido.produtos_quantidades.each do |pq|
      t += pq.qtd * pq.produto.preco
    end
    return t
  end
  
  def formata_cpf(cpf)
    if cpf and not cpf.blank?
      return "#{cpf[0..2]}.#{cpf[3..5]}.#{cpf[6..8]}-#{cpf[9..10]}"
    else
      return "<i>CPF não informado</i>"
    end
  end
  
end