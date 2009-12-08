require 'digest/sha1'
class Pessoa < ActiveRecord::Base
  has_many :pedidos
  
  #==================================================================================#
  #                                VALIDATIONS                                       #
  #==================================================================================#
  # got this in: http://opensoul.org/2007/2/7/validations-on-empty-not-nil-attributes
  before_validation :clear_empty_attrs

  validates_presence_of :nome 
  validates_presence_of :email
  validates_presence_of :sexo
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_inclusion_of :sexo, :in => %w( m f )
  validates_numericality_of :cpf, :only_integer => true, :allow_nil => true # = skip validation
  validates_length_of :cpf, :is => 11, :allow_nil => true # = skip validation
  validates_length_of :rg, :maximum => 20, :allow_nil => true # = skip validation
  #validates_uniqueness_of :email #, :scope => :cpf

  def qual_sexo
    return "masculino" if (self.sexo=="m")
    return "feminino " if (self.sexo=="f")
  end
  
  def to_label
    str  = "#{self.nome} (#{self.email})"
    str += ", CPF #{self.cpf}" if self.cpf and not self.cpf.empty?
    return str
  end
  
  def primeiro_nome
    nomes = self.nome.split(' ')
    return nomes[0] if nomes
  end
  
  def termina_o_a
    return "o" if self.sexo == 'm'
    return "a" if self.sexo == 'f'
  end
    
  def md5
    return Pessoa.encrypt("#{self.email}".reverse,"#{self.id}")
  end
    
  protected
  
  def self.encrypt(str, salt)
    Digest::SHA1.hexdigest(str.to_s + salt.to_s)
  end  
end
