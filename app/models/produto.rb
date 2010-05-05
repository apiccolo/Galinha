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
      s = self.find(:all, 
                    :conditions => ["id IN (?)", default_on_empty.split(',')], 
                    :order => "id DESC")
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
  
  # A ser implementado pelos filhos
  #def baixa_no_estoque(qtd)
  #end
  
  #======================================================#
  #                   CLASS   METHODS                    #
  #======================================================#
  
  # Retorna o total de produtos vendidos
  # (dentro de um intervalo etc.)
  def self.vendidos(my_options = {})
    options = {
      :de => 30.days.ago,
      :ate => Date.today,
      :order => "vendidos ASC"
    }.merge!(my_options)

    condicoes = []
    condicoes << "pedidos.forma_pgmto <> 'INDEFINIDO'"
    condicoes << "pedidos.status <> 'aguardando_pagamento'"
    condicoes << "pedidos.status <> 'pedido_cancelado'"
    condicoes << "pedidos.status <> 'pedido'"
    condicoes << "pedidos.data_pgmto >= '#{options[:de].strftime('%Y-%m-%d')}'"
    condicoes << "pedidos.data_pgmto <= '#{options[:ate].strftime('%Y-%m-%d')}'"

    sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
    SELECT produtos.*, Z.vendidos FROM produtos
    INNER JOIN (
      SELECT produto_id, SUM(qtd) AS vendidos 
      FROM produtos_quantidades
      WHERE pedido_id IN (
        SELECT id FROM pedidos 
        WHERE #{condicoes.join(' AND ')}
      )
      GROUP BY produto_id
    ) Z
    ON (produtos.id = Z.produto_id)
    ORDER BY #{options[:order]}
MYSTRING
    return ProdutoCombo.find_by_sql(sql_string)
  end
end
