require 'digest/sha1'
class Desconto < ActiveRecord::Base
  belongs_to :pedido
  
  attr_accessor_with_default :enviar_email, true
  
  validates_presence_of :email, :valor
  validates_uniqueness_of :codigo, :allow_nil => true
  #validar se o cupom criado nao é já passado...
  
  after_create :gerar_codigo_desconto
  
  def gerar_codigo_desconto
    self.codigo = Digest::SHA1.hexdigest(self.created_at.to_s).to_s[0..20]
    self.save(false)
  end
  
  def usou?
    (self.pedido_id and not self.usado_em.blank?)
  end
  
  # Melhor trocar por um observe...
  #
  #after_create :notificar_ganhador_do_desconto
  #
  #def notificar_ganhador_do_desconto(enviar_email)
  #  if enviar_email
  #    
  #  end
  #end
end
