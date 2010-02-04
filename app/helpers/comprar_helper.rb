module ComprarHelper
  
  # TODO = Remove-me!!! vide carrinho e resumo_carrinho
  def calcular_preco(carrinho_item, produto)
    preco_item  = produto.preco
    preco_item += produto.plus_presente if carrinho_item.presente
    
    preco_final = preco_item * carrinho_item.qtd
    return preco_final
  end
  
  # Dado um valor (float), devolver string
  # para passar ao uolpagseguro: R$ 1,27 = 127
  def preco_pagseguro(valor)
    return (valor * 100).round.to_i.to_s
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
  
  def thumbs_imagens_na_pasta(produto, my_options = {})
    str = ''
    thumbs = Dir["#{RAILS_ROOT}/public/images/produtos/#{produto.imagem_pequena}*_thumb.png"]
    thumbs.reverse.each do |t|
      str += content_tag(:li, link_to_remote(image_tag(t.gsub("#{RAILS_ROOT}/public", ''), :class => "small_thumb"), 
                                             :url => { :action => "imagem", :thumb => t.gsub("#{RAILS_ROOT}/public", '') },
                                             :update => "imagem_grande",
                                             :before => "$('spinner').show()",
                                             :complete => "$('spinner').hide()") )
    end
    return str 
  end
  
  def produto_faltante_para_completar_combo(produto_combo, carrinho)
    ids_no_carrinho = Carrinho.produto_simples_ids(carrinho)
    p_id = produto_combo.produto_ids - ids_no_carrinho
    return ProdutoSimples.find(p_id[0]) if (p_id.size == 1)
    return nil
  end
  
end
