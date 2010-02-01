class Produto < ActiveRecord::Base
  has_many :pedidos, :through => :produtos_quantidades
  has_many :produtos_quantidades
  
  has_many :sugestoes, :limit => 4
  has_many :produtos_relacionados, 
           :through => :sugestoes,
           :source => :sugestao
  
  #==========================================================================#
  #                               VALIDATIONS                                #
  #==========================================================================#
  validates_presence_of :nome, :descricao
  
  
  #==========================================================================#
  #                               NAMED SCOPES                               #
  #==========================================================================#
  named_scope :disponivel, :conditions => [ "produtos.disponivel = ? AND produtos.qtd_estoque > ?", true, 0 ]

  
  #==========================================================================#
  #                             CLASS  METHODS                               #
  #==========================================================================#
  
  #------------------------------------------------------
  #   Dado um carrinho com produtos, devolve os 
  #   produtos relacionados
  #
  def self.sugere_demais_produtos(carrinho, default_on_empty)
    if carrinho and not carrinho.blank?
      s = []
      carrinho.each do |c|
        p = Produto.find(c.produto_id)
        p.produtos_relacionados.each { |p| s << p }
      end
    else
      #logger.debug("# ====> #{default_on_empty}")
      s = self.find(:all, :conditions => ["id IN (?)", default_on_empty.split(',')])
    end
    return s
  end
  
  #======================================================#
  #                  OBJECT   METHODS                    #
  #======================================================#
  def to_label
    "#{self.nome}"
  end
  
  # O produto pode ser vendido?
  # Pode ser listado no formulário de compra?
  def pode_ser_vendido?
    return (self.disponivel and (self.qtd_estoque > 0))
  end

  # Retorna o peso em kg
  def peso_kg
    self.peso/1000
  end
  
  # Retorna o codigo do produto
  # para a impressão da nota fiscal.
  def codproduto
    return "%03d" % self.id
  end
end
