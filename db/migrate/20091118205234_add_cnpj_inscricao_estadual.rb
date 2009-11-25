class AddCnpjInscricaoEstadual < ActiveRecord::Migration
  def self.up
    add_column :pessoas, 'cnpj', :string, :limit => 30
    add_column :pessoas, 'inscricao_estadual', :string, :limit => 20
  end

  def self.down
    remove_column :pessoas, :cnpj
    remove_column :pessoas, :inscricao_estadual
  end
end
