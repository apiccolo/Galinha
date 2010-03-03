require 'digest/sha1'
class Desconto < ActiveRecord::Base
  belongs_to :pedido
  
  #attr_accessor_with_default :enviar_email, true
  
  validates_presence_of :email, :valor
  validates_uniqueness_of :codigo, :allow_nil => true
  #validar se o cupom criado nao é já passado...
  
  after_create :gerar_codigo_desconto, :notificar_contemplado  
  def gerar_codigo_desconto
    self.codigo = Digest::SHA1.hexdigest(self.created_at.to_s).to_s[0..19]
    self.save(false)
  end
  
  def notificar_contemplado
    Mailer.deliver_novo_desconto(self) unless self.codigo.blank?
  end

  after_save :marcar_usado_em
  def marcar_usado_em
    if self.pedido_id and self.usado_em.blank?
      self.usado_em = Time.now.utc if self.pedido_id
      self.save(false)
    end
  end

  def cupom
    self.codigo
  end
  
  def usou?
    (!self.usado_em.blank? and self.pedido_id)
  end
  
  def expirado?
    (self.valido_ate < Time.now)
  end
  
  #
  # Dado um cupom, digitado pelo usuario,
  # procurar se ele existe e se é valido.
  # (= nao expirado e ainda nao foi usado)
  #
  def self.valida_cupom(cupom)
    cupom = find_by_codigo(cupom)
    if cupom
      if cupom.expirado?
        return [ false, 'Prazo de validade expirado deste cupom' ]
      elsif cupom.usou?
        return [ false, 'Este cupom já foi utilizado' ]
      else
        return [ true, cupom ]
      end
    else
      return [ false, 'Cupom inexistente' ]
    end
  end
  
end
