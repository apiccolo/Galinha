class CreateDescontos < ActiveRecord::Migration
  def self.up
    create_table :descontos do |t|
      t.string   :codigo
      t.string   :email
      t.integer  :valor
      t.datetime :valido_ate
      t.integer  :pedido_id
      t.datetime :usado_em

      t.timestamps
    end
  end

  def self.down
    drop_table :descontos
  end
end
