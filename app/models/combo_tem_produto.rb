class ComboTemProduto < ActiveRecord::Base
  #belongs_to :produto_combo, :foreign_key => "combo_id"
  #belongs_to :produto

  #validates_uniqueness_of :produto_id, :scope => :combo_id
end
