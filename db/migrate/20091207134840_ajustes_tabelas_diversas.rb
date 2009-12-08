class AjustesTabelasDiversas < ActiveRecord::Migration
  def self.up
    add_column "produtos_quantidades", "preco_unitario", :float
    add_column "pessoas", "como_conheceu", :string, :limit => 30
  end

  def self.down
    remove_column "produtos_quantidades", "preco_unitario"
    remove_column "pessoas", "como_conheceu"
  end
end
