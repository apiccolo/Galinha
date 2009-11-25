class CreateProdutosQuantidades < ActiveRecord::Migration
  def self.up
    create_table :produtos_quantidades, :id => false do |t|
      t.integer :pedido_id
      t.integer :produto_id
      t.integer :qtd
      t.boolean :presente, :default => false
      t.timestamps
    end
    add_index :produtos_quantidades, :pedido_id
    add_index :produtos_quantidades, :produto_id
  end

  def self.down
    drop_table :produtos_quantidades
  end
end
