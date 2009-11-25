class CreatePedidos < ActiveRecord::Migration
  def self.up
    create_table :pedidos do |t|
      t.integer :pessoa_id
      t.string :status, :limit => 30, :default => 'PEDIDO'
      t.string :forma_pgmto, :limit => 100, :default => 'INDEFINIDO'
      t.float  :frete, :default => 0
      t.float  :desconto, :default => 0
      t.timestamp :data_pedido
      t.timestamp :data_pgmto
      t.timestamp :data_envio
      t.timestamp :data_recebimento
      t.string :entrega_nome_pacote, :limit => 50
      t.string :entrega_endereco, :limit => 100
      t.string :entrega_numero, :limit => 10
      t.string :entrega_complemento
      t.string :entrega_bairro, :limit => 50
      t.string :entrega_cep, :limit => 10
      t.string :entrega_cidade, :limit => 50
      t.string :entrega_estado, :limit => 2
      t.string :codigo_postagem, :limit => 50
      t.text :obs
      t.timestamps
    end
    add_index :pedidos, :pessoa_id
    add_index :pedidos, :status
  end

  def self.down
    drop_table :pedidos
  end
end
