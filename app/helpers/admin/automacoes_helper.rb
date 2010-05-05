module Admin::AutomacoesHelper
  
  def pedidos_selecionados_em_ul(ps)
    if ps
      aux = []
      ps.each do |p|
        pedido = Pedido.find(p) unless (p == "empty") #arrays first position
        if pedido
          text  = image_tag("icones/heart_delete.png") + "Pedido #{pedido.id}<br />NF <b>#{pedido.nota_fiscal}</b>"
          link  = link_to_remote(text, :url => { 
                                          :controller => "admin/pedidos",
                                          :action => "nf_marcar",
                                          :id => pedido },
                                  :html => { :title => "Desmarcar NF #{pedido.nota_fiscal} " } )
          link += hidden_field_tag('pedidos_ids[]', pedido.id, :id => "hidden_#{pedido.id}")
          # Concatena <li>...
          aux << [ pedido.nota_fiscal, content_tag(:li, link, :id => "heart_#{pedido.id}", :class => "pedido") ]
        end
      end
      
      lis = "" # ordena por ordem de nota fiscal...
      aux.sort!{ |x, y| x[0] <=> y[0] }.each{ |k| lis += k[1] }
      
      return content_tag(:ul, lis, :id => "blocado", :class => "clearfix") unless lis.blank?
      return content_tag(:p, "Não há pedidos marcados.", :class => "negrito margin0")
    else
      return content_tag(:p, "Não há pedidos marcados. Settings['pedidos_selecionados'] vazia!", :class => "negrito margin0")
    end
  end
  
  def acumula_totais(t, p)
    t[0] += p.total_sem_frete_sem_desconto
    p.produtos_quantidades.each do |r|
      if (t[1].has_key?(r.produto_id))
        t[1][r.produto_id] += r.qtd
      else
        t[1].merge!({ r.produto_id => r.qtd })
      end
    end
  end

end