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
  named_scope :disponivel, :conditions => [ "produtos.disponivel = ?", true ]

  
  #==========================================================================#
  #                             CLASS  METHODS                               #
  #==========================================================================#
  
  #------------------------------------------------------
  #   Dado um carrinho com produtos, devolve os 
  #   produtos relacionados
  #
  def self.sugere_demais_produtos(carrinho)
    if carrinho and not carrinho.blank?
      s = []
      carrinho.each do |c|
        p = Produto.find(c.produto_id)
        p.produtos_relacionados.each { |p| s << p }
      end
    else
      s = self.find(:all, :limit => 4, :order => "RANDOM()")
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
