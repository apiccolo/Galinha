module SharedHelper

  def infos_produto_box(produto, my_options = {})
    options = {
      :link_to_carrinho => true,
      :mostrar_preco => true,
      :mostrar_desconto => false,
      :mostrar_itens => false,
      :mostrar_itens_links_retirar => true
    }
    options = options.merge!(my_options)
    
    render :partial => "shared/infos_#{produto.class.to_s.underscore.downcase}",
           :locals => { 
             :produto => produto,
             :options => options
           }
  end

  def infos_leve_tambem(pc, carrinho, my_options = {})
    options = {
      :link_to_carrinho => true
    }
    options = options.merge!(my_options)
    render :partial => "shared/infos_leve_tambem",
           :locals => { 
             :produto_combo => pc,
             :carrinho => carrinho,
             :options => options
           }
  end

end
