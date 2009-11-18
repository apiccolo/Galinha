require "bcrypt"

class Administrador < ActiveRecord::Base
  validates_presence_of :nome, :email

  attr_accessor :senha_digitada, :senha_digitada_confirmation
  with_options :if => :validar_senha? do |nova_senha|
    nova_senha.validates_presence_of     :senha_digitada
    nova_senha.validates_length_of       :senha_digitada, :within => 6..40
    nova_senha.validates_confirmation_of :senha_digitada
  end

  # A senha deve ser encriptada antes de ser salva.
  before_save :encriptar_senha

  # Retorna o usuário se a senha estiver correta. Caso contrário, retorna
  # false.
  def self.autenticar(email, senha)
    u = Administrador.find_by_email(email)
    if u and u.senha?
      BCrypt::Password.new(u.senha) == senha ? u : false
    else
      false
    end
  end

  protected

  # Encripta a senha apenas se for novo usuário ou mudança de senha. A partir
  # do atributo senha_digitada, usa o algoritmo do BCrypt para encriptar.
  def encriptar_senha
    return if self.senha_digitada.blank?
    self.senha = BCrypt::Password.create(self.senha_digitada)
  end

  # Retorna true se a senha deve ser validada: em novo usuário e em mudança
  # de senha.
  def validar_senha?
    self.senha.blank? || !self.senha_digitada.blank?
  end

end