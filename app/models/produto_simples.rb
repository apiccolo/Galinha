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
end