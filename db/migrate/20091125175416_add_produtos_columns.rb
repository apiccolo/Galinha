class AddProdutosColumns < ActiveRecord::Migration
  def self.up
    add_column "produtos", "descricao_simples", :string, :limit => 30
    add_column "produtos", "preco_fiscal", :float, :default => 0
    add_column "produtos", "type", :string, :limit => 20
    add_column "produtos", "desconto", :float, :default => 0

    create_table :combo_tem_produtos, :id => false do |t|
      t.integer  :combo_id
      t.integer  :produto_id
    end
    
    Produto.update_all("type = 'ProdutoSimples'")
  end

  def self.down
    remove_column "produtos", "descricao_simples"
    remove_column "produtos", "preco_fiscal"
    remove_column "produtos", "type"
    remove_column "produtos", "desconto"
    
    drop_table :combo_tem_produtos
  end
end
