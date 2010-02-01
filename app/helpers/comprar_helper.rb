module ComprarHelper
  
  # TODO = Remove-me!!! vide carrinho e resumo_carrinho
  def calcular_preco(carrinho_item, produto)
    preco_item  = produto.preco
    preco_item += produto.plus_presente if carrinho_item.presente
    
    preco_final = preco_item * carrinho_item.qtd
    return preco_final
  end
  
  # Dado um produto (obj), retorna a imagem
  # em formato pequeno (50 de altura) ~ thumbnail
  def thumbnail_produto(produto, my_options = {})
    options = {
      :class => "thumbnail"
    }
    options = options.merge!(my_options)
    image_tag("produtos/#{produto.imagem_pequena}_thumb.png", options)
  end
  
  def imagem_produto(produto, my_options = {})
    options = {
      :class => ""
    }
    options = options.merge!(my_options)
    image_tag("produtos/#{produto.imagem_pequena}.png", options)
  end
  
  def produto_faltante_para_completar_combo(produto_combo, carrinho)
    ids_no_carrinho = Carrinho.produto_simples_ids(carrinho)
    p_id = produto_combo.produto_ids - ids_no_carrinho
    return ProdutoSimples.find(p_id[0]) if (p_id.size == 1)
    return nil
  end
  
end
