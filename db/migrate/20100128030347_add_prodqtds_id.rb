class AddProdqtdsId < ActiveRecord::Migration
  def self.up
    add_column :produtos_quantidades, :id, :primary_key
  end

  def self.down
    remove_column :produtos_quantidades, :id
  end
end
