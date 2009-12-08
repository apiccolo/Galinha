class ProdutosQuantidade < ActiveRecord::Base
  belongs_to :pedido
  belongs_to :produto
  
  #===========================================================================#
  #                              VALIDATIONS                                  #
  #===========================================================================#
  validates_presence_of :produto_id, :qtd
  validates_presence_of :pedido_id, :if => Proc.new { |pq| not pq.criando_pedido }
  
  
  #===========================================================================#
  #                                 METHODS                                   #
  #===========================================================================#  
  def to_label
    tmp  = "#{self.qtd} #{self.produto.nome}"
    tmp += " (Para presente!)" if self.presente
    return tmp
  end
  
  # Retorna o codigo do produto
  # para a impressão da nota fiscal.
  # Coloca um "P" ao final se for presente... 
  def codproduto
    str = self.produto.codproduto
    str = "002" if self.presente
    return str
  end
    
  # Retorna a descricao do produto
  # para nota fiscal
  def nf_descricao
    str = self.produto.descricao
    str += " p/ pres." if self.presente
    return str
  end
  
  # Retorna o valor unitario do produto
  # para imprimir a nota fiscal.
  def nf_valorunit
    # ANTIGO FORMATO: 4.85
    valor_do_frete = 10.9
    val = (self.produto.preco - valor_do_frete)
    val += self.produto.plus_presente if self.presente
    return val
  end
  
  def nf_valortotal
    mult = (self.nf_valorunit * self.qtd)
    mult -= self.pedido.desconto if (self.pedido.desconto and (self.pedido.desconto > 0))
    return mult
  end
  
  # Se está criando o pedido (i.e. pedido ainda 
  # não foi salvo, por exemplo "Pedido.new(...)" ),
  # retorna TRUE; senão FALSE.
  def criando_pedido
    self.new_record?
  end
  
end
