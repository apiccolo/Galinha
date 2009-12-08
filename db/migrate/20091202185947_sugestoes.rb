class Sugestoes < ActiveRecord::Migration
  def self.up
    create_table :sugestoes do |t|
      t.integer  :produto_id
      t.integer  :produto_sugerido_id
      t.integer  :position
    end
  end

  def self.down
    drop_table :sugestoes
  end
end
