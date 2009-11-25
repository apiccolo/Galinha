class AddProdutosColumns < ActiveRecord::Migration
  def self.up
    add_column "produtos", "descricao_simples", :string, :limit => 30
    add_column "produtos", "preco_fiscal", :float, :default => 0
  end

  def self.down
    remove_column "produtos", "descricao_simples"
    remove_column "produtos", "preco_fiscal"
  end
end
