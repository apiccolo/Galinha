class AjusteDescontos < ActiveRecord::Migration
  def self.up
    add_column :descontos, :minimo_pedido, :float, :default => 0
  end

  def self.down
    delete_column :descontos, :minimo_pedido
  end
end
