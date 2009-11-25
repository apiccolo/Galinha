class CreatePessoas < ActiveRecord::Migration
  def self.up
    create_table :pessoas do |t|
      t.string :nome, :limit => 100
      t.string :email, :limit => 100
      t.string :chave_cookie
      t.string :sexo, :limit => 1, :default => 'm'
      t.date :nascimento
      t.string :cpf, :limit => 12
      t.string :rg, :limit => 20
      t.string :fone_ddd, :limit => 5
      t.string :fone_str, :limit => 10
      t.timestamps
    end
    add_index :pessoas, :nome
    add_index :pessoas, :email
    add_index :pessoas, :chave_cookie
  end

  def self.down
    drop_table :pessoas
  end
end
