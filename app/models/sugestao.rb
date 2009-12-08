class Sugestao < ActiveRecord::Base
  #set_table_name "sugestoes"
  
  belongs_to :produto, :class_name => "Produto", :foreign_key => "produto_id"
  belongs_to :sugestao, :class_name => "Produto", :foreign_key => "produto_sugerido_id"
  
  acts_as_list :scope => "produto_id"
  #===================================================#
  #                   VALIDATIONS                     #
  #===================================================#
  #validates_presence_of :preco, :preco_fiscal
end