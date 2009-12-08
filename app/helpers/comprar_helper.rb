module ComprarHelper
  
  def calcular_preco(carrinho_item, produto)
    preco_item  = produto.preco
    preco_item += produto.plus_presente if carrinho_item.presente
    
    preco_final = preco_item * carrinho_item.qtd
    return preco_final
  end
  
  # Dado um produto (obj), retorna a imagem
  # em formato pequeno (50 de altura) ~ thumbnail
  def thumbnail_produto(produto, options = {})
    options = {
      :class => "thumbnail"
    }
    options = options.merge!(options)
    image_tag("produtos/#{produto.imagem_pequena}_thumb.png", :class => options[:class])
  end
  
end
