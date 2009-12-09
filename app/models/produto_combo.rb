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
    return nil if (carrinho.nil? or (carrinho.size <= 0) or (carrinho.size > 3))
    aux = []
    carrinho.each do |c|
      produto_no_carrinho = Produto.find(c.produto_id)
      if (produto_no_carrinho.class == ProdutoSimples)
        ProdutoCombo.n_itens.each do |pc|
          aux << pc if pc.produtos.include?(produto_no_carrinho)
        end
        #p = ProdutoCombo.find(:first, 
        #                  :conditions => ["combo_tem_produtos.produto_id = ?", produto_no_carrinho.id], 
        #                  :include => :produtos)
        # aux << ProdutoCombo.find(p.id) # A consulta acima devolve rows estranhas... melhor devolver um legitimo ProdutoCombo
      end
    end
    return aux
  end
  
  #------------------------------------------------
  #   Retorna quantos itens tem em cada combo
  #
  def self.n_itens(my_options = {})
    #condicoes = []
    #condicoes << "1=1"
    #condicoes << "locais.pais_id = #{options[:pais].id}" if options[:pais]
    options = {
      :order => "total ASC"
    }
    options = options.merge!(my_options)
    
    sql_string = <<MYSTRING.gsub(/\s+/, " ").strip
    SELECT produtos.*, Z.total FROM produtos
    INNER JOIN (
      SELECT combo_id, count(*) AS total 
      FROM combo_tem_produtos
      GROUP BY combo_id
    ) Z
    ON (produtos.id = Z.combo_id)
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
  
  # A disponibilidade do combo é a disponibilidade
  # dos itens (AND) sua propria disponibilidade.
  def disponivel
    a_priori = true
    self.produtos.each { |p| a_priori = a_priori && p.disponivel }
    return a_priori    
  end
  
  def disponivel=(valor)
    a_priori = true
    self.produtos.each { |p| a_priori = a_priori && p.disponivel }
    write_attribute(:disponivel, a_priori)
  end

end
