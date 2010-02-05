module SharedHelper

  #
  # Mostra descricao mais extensa do produto
  # com/sem imagens (para modalbox, lista de produtos)
  def descreve_produto(produto, my_options = {})
    options = {
      :mostrar_thumbs => true
    }
    options = options.merge!(my_options)
    
    render :partial => "shared/descricao_produto",
           :locals => { 
             :produto => produto,
             :options => options
           }
  end

  #
  # Mostra informacoes principais do produto (simples e combo)
  # numa linha resumida (para carrinho, display e outros)
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
