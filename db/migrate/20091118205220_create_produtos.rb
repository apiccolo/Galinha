class CreateProdutos < ActiveRecord::Migration
  def self.up
    create_table :produtos do |t|
      t.string :nome
      t.text :descricao
      t.boolean :disponivel, :default => true
      t.integer :qtd_estoque, :default => 0
      t.float :peso
      t.string :tamanho
      t.float :preco, :default => 29.9
      t.float :plus_presente, :default => 0.5
      t.string :imagem_pequena
    end
    add_index :produtos, :nome
    add_index :produtos, :preco
  end

  def self.down
    drop_table :produtos
  end
end
