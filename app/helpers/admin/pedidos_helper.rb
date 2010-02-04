module Admin::PedidosHelper
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

  #======================================#
  #  METODOS q integram ACTIVE-SCAFFOLD  #
  #======================================#
  def data_pedido_column(record)
    record.data_pedido.strftime("%a, %d de %B<br />%d/%m/%Y às %H:%M") if record.data_pedido
  end
  
  def data_pgmto_column(record)
    record.data_pgmto.strftime("%d/%m/%Y às %H:%M") if record.data_pgmto
  end
  
  def comprador_column(record)
    str = "#{record.pessoa.nome}<br />"
    str += link_to(record.pessoa.email, 
                  {
                    :action => :edit, 
                    :controller => 'pessoas', 
                    :id => record.pessoa.id,
                    :parent_controller => "admin/pedidos",
                    :authenticity_token => form_authenticity_token
                   }, {
                    :id => "admin_pedidos_pessoa-edit-#{record.pessoa.id}-link",
                    :class => "action",
                    :position => "after"
                   }) #para editar email do comprador...
    #str += "#{record.pessoa.email}"
    str += "<br />"
    if record.pessoa.cpf and not record.pessoa.cpf.blank?
      str += formata_cpf(record.pessoa.cpf)
    else
      str += "<i>CPF não informado</i>"
    end
    if record.processando_envio? or record.processando_envio_envelopado?
      str += "<br />"
      str += link_to('imprimir nota fiscal', 
                    { :action => 'print', 
                      :id => record.id,
                      :nota_fiscal => 1 }, 
                      :class => 'etiqueta', 
                      :popup => ["status=1,toolbar=0,location=0,menubar=1,resizable=1,width=800,height=650"])
    elsif record.processando_envio_notafiscal? or record.produto_enviado? or record.produto_enviado_cod_postagem? or record.recebido_pelo_cliente? or record.encerrado?
      str += "<br />"
      str += "NF: <b>#{record.nota_fiscal}</b>"
    end
    return str
  end
  
  def total_column(record)
    number_to_currency(record.total, :precision => 2, 
                                     :unit => 'R$ ', 
                                     :separator => ",", 
                                     :format => "%u %n") if record.total
  end

  def status_column(record)
    case record.status
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
    str = content_tag(:span, record.status.humanize, :style => style_str)
    str = content_tag(:b, str) if str.include?('Processando')
    
    if (record.retornos_pgmtos.size > 0)
      str += "<br />Retornos Auto: "  
      links = []
      record.retornos_pgmtos.each_with_index do |retorno, i|
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
  
  def etiqueta_column(record)
    tmp  = "<span class=\"para_text\">Para: </span>"
    tmp += link_to('imprimir envelope', 
                  { :action => 'print', 
                    :id => record.id }, 
                    :class => 'etiqueta', 
                    :popup => ["status=1,toolbar=0,location=0,menubar=1,resizable=1,width=800,height=650"]) if record.processando_envio? or record.processando_envio_envelopado?
    tmp += "<br />"
    tmp += "<span class=\"para_nome\">"
    if record.entrega_nome_pacote and not record.entrega_nome_pacote.empty?
      tmp += "#{record.entrega_nome_pacote}"
      tmp += "</span><br /><span class=\"para_nome_ou\">#{record.pessoa.nome}" if (record.entrega_nome_pacote.strip != record.pessoa.nome.strip)
    else
      tmp += record.pessoa.nome
    end
    tmp += "</span>"
    tmp += "<br />"
    
    lnk  = "#{record.entrega_endereco}"
    lnk += ", #{record.entrega_numero}" if record.entrega_numero
    lnk += " #{record.entrega_complemento}" if record.entrega_complemento
    lnk += "<br />"
    lnk += "#{record.entrega_bairro}" if record.entrega_bairro
    lnk += "<br />"
    lnk += "#{record.cep} - #{record.entrega_cidade} - #{record.entrega_estado}"
    tmp += lnk
    #tmp += link_to(lnk, {
    #                 :action => "edit_endereco_entrega", 
    #                 :id => record.id,
    #                 :authenticity_token => form_authenticity_token
    #               }, {
    #                 :id => "admin_pedidos_endereco_entrega-edit-#{record.id}-link",
    #                 :class => "action",
    #                 :position => "after"
    #               })
    
    return tmp
  end
  
  def pre_column(record)
    str  = ""
    str += image_tag("icons/para_presente.gif", :style => "margin:0;") if record and record.produtos_quantidades and record.produtos_quantidades.first and record.produtos_quantidades.first.presente
    return str
  end
  
  def ree_column(record)
    str = ""
    if record.produto_enviado? or 
       record.produto_enviado_cod_postagem? or 
       record.recebido_pelo_cliente? or 
       record.encerrado?
      str += link_to image_tag("icons/arrow_refresh.png"), 
                     { :action => "reenviar_pedido",
                       :id => record.id,
                       :parent_controller => "admin/pedidos",
                       :authenticity_token => form_authenticity_token },
                     {
                       :confirm => "Deseja mesmo reenviar o pedido #{record.id}?",
                       :title => "Reenviar pedido #{record.id}",
                       :id => "admin_pedidos_reenviar-#{record.pessoa.id}-link",
                       :class => "action",
                       :position => false }
    end
    if (record.reenvio.to_i > 0)
      str += "<br /><span title=\"último reenvio em #{record.reenviado_em.strftime("%d/%m/%Y às %H:%M")}\">#{record.reenvio}x</span>"
    end
    return str
  end
  
  def mudar_para_form_column(record, input_name)
    tmp  = '<div style="font-family:verdana;sans-serif;font-size:11px;font-weight:bold">'
    tmp += radio_button_tag(input_name, "pedido", record.status=="pedido")+content_tag(:span, "Pedido ainda não enviado para UOL-PagueSeguro.<br />", :style => "color:#00AAEF")
    tmp += radio_button_tag(input_name, "aguardando_pagamento", record.status=="aguardando_pagamento")+content_tag(:span,"Pedido aguardando pagamento.<br />", :style => "color:#00AAEF")
    tmp += radio_button_tag(input_name, "processando_envio", record.status=="processando_envio")+content_tag(:span,"Pagamento confirmado.<br />", :style => "color:#FF335D")
    tmp += radio_button_tag(input_name, "processando_envio_envelopado", record.status=="processando_envio_envelopado")+content_tag(:span,"Pedido envelopado.<br />", :style => "color:#FF335D")
    tmp += radio_button_tag(input_name, "processando_envio_notafiscal", record.status=="processando_envio_notafiscal")+content_tag(:span,"Nota fiscal impressa.<br />", :style => "color:#FF335D")
    tmp += radio_button_tag(input_name, "produto_enviado", record.status=="produto_enviado")+content_tag(:span, "Produto postado no correio.<br />", :style => "color:#5CCC35")
    tmp += radio_button_tag(input_name, "produto_enviado_cod_postagem", record.status=="produto_enviado_cod_postagem")+content_tag(:span, "Produto com codigo de postagem.<br />", :style => "color:#5CCC35")
    tmp += radio_button_tag(input_name, "pedido_cancelado", record.status=="pedido_cancelado")+content_tag(:span, "Pedido cancelado.<br />", :style => "color:#9F99A2")
    tmp += radio_button_tag(input_name, "recebido_pelo_cliente", record.status=="recebido_pelo_cliente")+content_tag(:span, "Produto recebido.<br />", :style => "color:#929122")
    tmp += radio_button_tag(input_name, "encerrado", record.status=="encerrado")+content_tag(:span, "Pedido encerrado!<br />", :style => "color:#498849")
    tmp += '</div>'
    return tmp
  end
  
  # Dado um Hash, cujos valores são
  # inteiros, devolve a soma destes.
  def soma(totais)
    aux = 0
    totais.each{ |k, v| aux += v.to_i }
    return aux
  end
  
  def formata_cpf(cpf)
    return "#{cpf[0..2]}.#{cpf[3..5]}.#{cpf[6..8]}-#{cpf[9..10]}"
  end
  
  def prestar_atencao(status, pedido)
    return ((status=="Aprovado" or status=="Completo") and pedido.aguardando_pagamento?)
  end

  #================================#
  #  METODOS q integram IMPRESSAO  #
  #================================#
  def querystring_para_notafiscal(pedido)
    q  = ""
    q += "codvendas="
    q += (pedido.entrega_estado=='SP') ? "5.102" : "6.102"
    q += "&"
    q += "dataemissao="
    q += CGI::escape(Time.now.strftime("%d/%m/%Y"))
    q += "&"
    q += "stringdata="
    q += (pedido.data_nf) ? CGI::escape(pedido.data_nf.strftime("%d/%m/%Y")) : CGI::escape(Time.now.strftime("%d/%m/%Y"))
    q += "&"
    q += "nome="
    q += CGI::escape(pedido.pessoa.nome)
    q += "&"
    q += "cpf="
    # se eh empresa
    if (pedido.pessoa.cnpj and not pedido.pessoa.cnpj.blank?)
      q += CGI::escape(pedido.pessoa.cnpj)
      q += "&"
      q += "inscricao="
      q += CGI::escape(pedido.pessoa.inscricao_estadual)
      q += "&"
    else
      q += (pedido.pessoa.cpf and not pedido.pessoa.cpf.blank?) ? formata_cpf(pedido.pessoa.cpf) : CGI::escape("não informado")
    end    
    q += "&"
    q += "endereco="
    q += CGI::escape(pedido.entrega_endereco.to_s+", "+pedido.entrega_numero.to_s+" "+pedido.entrega_complemento.to_s)
    q += "&"
    q += "bairro="
    q += CGI::escape(pedido.entrega_bairro) if pedido.entrega_bairro
    q += "&"
    q += "cep="
    q += CGI::escape(pedido.cep)
    q += "&"
    q += "cidade="
    q += CGI::escape(pedido.entrega_cidade)
    q += "&"
    q += "estado="
    q += CGI::escape(pedido.entrega_estado)
    q += "&"
    q += "codproduto="
    q += CGI::escape(pedido.produtos_quantidades[0].codproduto)
    q += "&"
    q += "descricao="
    q += CGI::escape(pedido.produtos_quantidades[0].nf_descricao)
    q += CGI::escape("\nPedido n. #{pedido.id}")
    q += "&"
    q += "quantidade="
    q += CGI::escape(pedido.produtos_quantidades[0].qtd.to_s)
    q += "&"
    q += "valorunit="
    valorunit = sprintf("%.2f", pedido.produtos_quantidades[0].nf_valorunit)
    q += CGI::escape(valorunit)
    q += "&"
    if (pedido.desconto and (pedido.desconto>0))
      q += "desconto="
      q += CGI::escape(pedido.desconto.to_s)
      q += "&"
    end
    q += "valortotal="
    valortotal = sprintf("%.2f", pedido.produtos_quantidades[0].nf_valortotal)
    q += CGI::escape(valortotal)
    q += "&"
    return q
  end
end
