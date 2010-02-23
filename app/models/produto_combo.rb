class ProdutoCombo < Produto
  has_and_belongs_to_many :produtos, 
                          :class_name => "ProdutoSimples",
                          :join_table => "combo_tem_produtos", 
                          :foreign_key => "combo_id",
                          :association_foreign_key => "produto_id"
  
  #===================================================#
  #                   VALIDATIONS                     #
  #===================================================#
  validates_presence_of :desconto

  #======================================================#
  #                   CLASS   METHODS                    #
  #======================================================#

  #------------------------------------------------
  #   Dado um carrinho de compras, sugerir
  #   produtos combos que apresentem descontos,
  #   a fim de motivar a compra
  #
  def self.leve_tambem(carrinho)
    return nil if (carrinho.nil? or (carrinho.size <= 0))
    carrinho_ids = []
    total_produtos = 0
    carrinho.each do |c|
      produto_no_carrinho = Produto.find(c.produto_id)
      if (produto_no_carrinho.class == ProdutoSimples)
        carrinho_ids << produto_no_carrinho.id
        total_produtos += 1
      elsif (produto_no_carrinho.class == ProdutoCombo)
        produto_no_carrinho.produto_ids.each { |pid| carrinho_ids << pid }
        total_produtos += produto_no_carrinho.produto_ids.size
      end
    end
    #logger.debug("======> #{total_produtos}")
    aux = []
    ProdutoCombo.n_itens(:order => "produtos.id DESC, total ASC", :n_itens_pacote => (total_produtos+1)).each do |pc|
      aux << pc if (pc.disponivel and 
                    ((pc.produto_ids - carrinho_ids).size.to_i == 1))
    end
    return aux
  end
  
  #------------------------------------------------
  #   Retorna quantos itens tem em cada combo
  #
  def self.n_itens(my_options = {})
    options = {
      :order => "total ASC"
    }
    options = options.merge!(my_options)
    condicoes = []
    condicoes << "1=1"
    condicoes << "produtos.qtd_estoque > 0"
    condicoes << "total = #{options[:n_itens_pacote]}" if options[:n_itens_pacote]
    
    sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
    SELECT produtos.*, Z.total FROM produtos
    INNER JOIN (
      SELECT combo_id, count(*) AS total 
      FROM combo_tem_produtos
      GROUP BY combo_id
    ) Z
    ON (produtos.id = Z.combo_id)
    WHERE #{condicoes.join(' AND ')}
    ORDER BY #{options[:order]}
MYSTRING
    return ProdutoCombo.find_by_sql(sql_string)
  end
  


  #======================================================#
  #                  OBJECT   METHODS                    #
  #======================================================#

  # PRECO do produto combo é o preco dos itens
  # decrescido do DESCONTO.
  def preco
    meu_preco = preco_fake
    meu_preco -= self.desconto
    return meu_preco
  end
  
  def preco=(valor)
    meu_preco  = preco_fake
    meu_preco -= self.desconto
    write_attribute(:preco, meu_preco)
  end
  
  def preco_fake
    meu_preco = 0
    self.produtos.each { |p| meu_preco += p.preco }
    return meu_preco
  end
  
  def qtd_estoque=(valor)
    #tmp = self.qtd_estoque #somehow, it didn't work...
    write_attribute(:qtd_estoque, 1999)
  end
  
  def qtd_estoque
    init = 0
    self.produtos.each { |p| init = p.qtd_estoque if ((init == 0) or (p.qtd_estoque < init)) }
    return init
  end
  
  # Diminui a quantidade vendida do estoque
  def baixa_no_estoque(qtd)
    self.produtos.each { |p| p.baixa_no_estoque(qtd) }
  end
  
  # A disponibilidade do combo é a disponibilidade
  # dos itens (AND) sua propria disponibilidade.
  def disponivel
    a_priori = read_attribute(:disponivel)
    self.produtos.each { |p| a_priori = a_priori && p.disponivel }
    return a_priori    
  end
  
  def disponivel=(valor)
    demais = valor
    #self.produtos.each { |p| demais = demais && p.disponivel }
    write_attribute(:disponivel, demais)
  end

end
