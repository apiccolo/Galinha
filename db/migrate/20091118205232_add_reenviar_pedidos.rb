class AddReenviarPedidos < ActiveRecord::Migration
  def self.up
    add_column :pedidos, 'reenvio', :integer, :default => 0
    add_column :pedidos, 'data_nf', :timestamp
  end

  def self.down
    remove_column :pedidos, :reenvio
    remove_column :pedidos, :data_nf
  end
end
