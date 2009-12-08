class RetornosPgmto < ActiveRecord::Base
  belongs_to :pedido
  
  #===============#
  #  VALIDATIONS  #
  #===============#
  validates_presence_of :pedido
  
  def to_label
    "Retorno: #{self.tipopagamento}, TransaçãoID: #{self.transacaoid}"
  end
end
