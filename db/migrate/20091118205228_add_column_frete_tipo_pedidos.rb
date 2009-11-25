class AddColumnFreteTipoPedidos < ActiveRecord::Migration
  def self.up
    add_column :pedidos, 'frete_tipo', :string, :limit => 20, :default => 'padrao'
    add_column :pedidos, 'reenviado', :boolean, :default => false
    add_column :pedidos, 'reenviado_em', :datetime
    
    # Tabela para guardar retornos do UOLPagSeguro
    create_table :retornos_pgmtos do |t|
      t.integer :pedido_id
      t.string  :transacaoid, :limit => 40
      t.string  :tipopagamento, :limit => 50
      t.string  :status, :limit => 50
      t.string  :tipofrete, :limit => 2
      t.integer :numitens
      t.text    :demais
      t.timestamps
    end
    
    add_index :retornos_pgmtos, :pedido_id
    add_index :retornos_pgmtos, :transacaoid
  end

  def self.down
    remove_column :pedidos, :frete_tipo
    remove_column :pedidos, :reenviado
    remove_column :pedidos, :reenviado_em
    
    drop_table :retornos_pgmtos
  end
end
