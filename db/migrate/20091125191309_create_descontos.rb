class CreateDescontos < ActiveRecord::Migration
  def self.up
    create_table :descontos do |t|
      t.string   :codigo, :limit => 50
      t.string   :email, :limit => 50
      t.integer  :valor
      t.datetime :valido_ate
      t.integer  :pedido_id
      t.datetime :usado_em

      t.timestamps
    end
    
    add_index "descontos", "codigo"
  end

  def self.down
    drop_table :descontos
  end
end
