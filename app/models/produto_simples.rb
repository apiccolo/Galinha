class ProdutoSimples < Produto
  has_and_belongs_to_many :combos, 
                          :class_name => "ProdutoCombo",
                          :join_table => "combo_tem_produtos", 
                          :foreign_key => "produto_id",
                          :association_foreign_key => "combo_id"

  #===================================================#
  #                   VALIDATIONS                     #
  #===================================================#
  validates_presence_of :preco, :preco_fiscal
  
  # Diminui a quantidade vendida do estoque
  def baixa_no_estoque(qtd)
    write_attribute(:qtd_estoque, (self.qtd_estoque - qtd))
    self.save(false)
  end

end