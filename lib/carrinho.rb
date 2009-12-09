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
  
end