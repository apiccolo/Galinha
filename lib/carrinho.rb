class Carrinho
    
  # Dado o carrinho, retornar array com ids
  # dos produtos que ele contem
  def self.produto_ids(carrinho)
    t = []
    if carrinho and (carrinho.size > 0)
      carrinho.each do |c|
        t << c.produto_id.to_i
      end
    end
    return t
  end
  
  # Dado o carrinho, retornar array com ids
  # dos produtos SIMPLES que ele contem, i.e.
  # se tiver produtos COMBOS, desmembra
  def self.produto_simples_ids(carrinho)
    t = []
    if carrinho and (carrinho.size > 0)
      carrinho.each do |c|
        p = Produto.find(c.produto_id)
        if p.class == ProdutoSimples
          t << p.id
        elsif p.class == ProdutoCombo
          p.produto_ids.each { |k| t << k }
        end
      end
    end
    return t
  end
  
end