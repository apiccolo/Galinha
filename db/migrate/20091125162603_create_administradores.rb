class CreateAdministradores < ActiveRecord::Migration
  def self.up
    create_table :administradores do |t|
      t.string :nome
      t.string :email
      t.string :senha

      t.timestamps
    end
    # Cria o primeiro user-admin
    Administrador.create(:nome => 'Admin', 
                         :email => 'contato@galinhapintadinha.com.br', 
                         :senha => '123456', 
                         :senha_digitada => '123456')
  end

  def self.down
    drop_table :administradores
  end
end
  