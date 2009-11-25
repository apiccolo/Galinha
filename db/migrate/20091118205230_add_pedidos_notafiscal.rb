class AddPedidosNotafiscal < ActiveRecord::Migration
  def self.up
    add_column :pedidos, 'nota_fiscal', :string, :limit => 50
  end

  def self.down
    remove_column :pedidos, :nota_fiscal
  end
end
