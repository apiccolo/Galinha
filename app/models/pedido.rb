class Pedido < ActiveRecord::Base
  # Quem fez o pedido
  belongs_to :pessoa
  
  # Produtos e Quantidades associados
  has_many :produtos, :through => :produtos_quantidades
  has_many :produtos_quantidades
  
  # Retornos do UOLPagSeguro
  has_many :retornos_pgmtos
  
  # Para mudanca de status...
  attr_accessor :mudar_para
  
  #===========================================================================#
  #                             VALIDATIONS                                   #
  #===========================================================================#
  validates_associated :pessoa
  validates_associated :produtos_quantidades
  validates_presence_of :entrega_endereco
  validates_presence_of :entrega_numero
  validates_presence_of :entrega_cep
  validates_presence_of :entrega_cidade 
  validates_presence_of :entrega_estado
  validates_length_of :entrega_endereco, :maximum => 100, :allow_nil => true
  validates_length_of :entrega_numero, :maximum => 10, :allow_nil => true
  validates_length_of :entrega_cidade, :maximum => 50, :allow_nil => true
  validates_length_of :entrega_estado, :maximum => 2, :allow_nil => true
  validates_length_of :entrega_cep, :is => 8
  validates_numericality_of :entrega_cep, :only_integer => true
  validate :must_have_produto
  
  def must_have_produto
    if produtos_quantidades.size <= 0
      errors.add_to_base("Carrinho precisa de ao menos um produto")
    end
  end

  #==========================================================================#
  #                               NAMED SCOPES                               #
  #==========================================================================#
  named_scope :posteriores_a, lambda { |data|
    if data.blank?
      {}
    else
      { :conditions => ["pedidos.data_envio >= ?", data] }
    end
  }
  named_scope :anteriores_a, lambda { |data|
    if data.blank?
      {}
    else
      { :conditions => ["pedidos.data_envio <= ?", data] }
    end
  }
  named_scope :nf_inicial, lambda { |nf_numero|
    if data.blank?
      {}
    else
      { :conditions => ["pedidos.nota_fiscal >= ?", nf_numero] }
    end
  }
  named_scope :nf_final, lambda { |nf_numero|
    if data.blank?
      {}
    else
      { :conditions => ["pedidos.nota_fiscal <= ?", nf_numero] }
    end
  }

  #==================================================================#
  #                           METHODS                                #
  #==================================================================#
  # Inclui os produtos e suas respectivas qtds no pedido
  def inclui_produtos_qtd(options = {})
    if options.include?('id') and options.include?('qtd')
      pq = ProdutosQuantidade.new(:pedido_id => self.id,
                                  :produto_id => options[:id],
                                  :qtd => options[:qtd],
                                  :presente => options.include?('presente')
                                  )
      pq.save!
    end
  end
  
  # Retorna o nome da pessoa para quem vai o(s) presente(s)
  def para
    if not self.entrega_nome_pacote.blank?
      self.entrega_nome_pacote
    else
      self.pessoa.nome
    end
  end
  
  # Calcula o valor total do pedido
  def total
    t = 0
    if self.produtos_quantidades
      preco_unit = 0
      for p in self.produtos_quantidades
        preco_unit  = p.produto.preco
        preco_unit += p.produto.plus_presente if p.presente
        t += p.qtd.to_i * preco_unit.to_f
      end
    end
    t += self.frete.to_f if self.frete
    t -= self.desconto.to_f if self.desconto
    return t.to_f
  end
  
  # Transforma o Id em Letras(=Base50)
  # Vide: lib/salt.rb
  def base50
    Salt.converteParaBase50(self.id)
  end
  
  # Verifica se tais dados batem
  # pois só seu dono os possui.
  def check(pid, pbase, chkpid, md5)
    return ((self.id.to_i == pid.to_i) and 
            (self.base50 == pbase) and
            (self.pessoa_id.to_i == chkpid.to_i) and
            (self.pessoa.md5 == md5))
  end
  
  # Métodos para ACTIVE SCAFFOLD
  # Reescritos no Helper.
  #=============================
  def to_label
    "PedidoId #{self.id}, feito por #{self.pessoa.primeiro_nome} em #{self.created_at.strftime('%d de %B')}"
  end
  
  def endereco
  end
  
  def change_status
  end
  
  # CEP no formato DDDDD-DDD
  def cep
    self.entrega_cep[0..4]+"-"+self.entrega_cep[5..8] if self.entrega_cep
  end
    
  #============================================================================#
  #                            ESTADOS dos PEDIDOS                             #
  #============================================================================#
  acts_as_state_machine :initial => :pedido, :column => 'status'

  # Estados disponíveis para os PEDIDOS
  state :pedido,                       :after => Proc.new {|model| model.inicia_pedido }
  state :aguardando_pagamento,         :after => Proc.new {|model| model.notifica_recebimento_pedido }
  state :processando_envio,            :after => Proc.new {|model| model.notifica_recebimento_pagamento }
  state :processando_envio_envelopado, :after => Proc.new {|model| model.pedido_envelopado }
  state :processando_envio_notafiscal, :after => Proc.new {|model| model.pedido_notafiscal }
  state :produto_enviado,              :after => Proc.new {|model| model.envia_produto }
  state :produto_enviado_cod_postagem, :after => Proc.new {|model| model.insere_cod_postagem }
  state :pedido_cancelado,             :after => Proc.new {|model| model.notifica_cancelamento }
  state :recebido_pelo_cliente,        :after => Proc.new {|model| model.depois_de_recebido }
  state :encerrado,                    :after => Proc.new {|model| model.notifica_encerramento }

  # Inicia o pedido
  event :iniciar do
    transitions :from => :pedido,                       :to => :aguardando_pagamento
  end
  
  # Confirma o pagamento
  event :pagamento_confirmado do
    transitions :from => :aguardando_pagamento,         :to => :processando_envio
  end

  # Envelopa o pedido
  event :envelopar do
    transitions :from => :processando_envio,            :to => :processando_envio_envelopado
  end

  # Imprime a nota fiscal do pedido
  event :imprimir_nota_fiscal do
    transitions :from => :processando_envio_envelopado, :to => :processando_envio_notafiscal
  end
  
  # Manda o produto ao correio
  event :enviar_correio do
    transitions :from => :processando_envio,            :to => :produto_enviado
    transitions :from => :processando_envio_envelopado, :to => :produto_enviado
    transitions :from => :processando_envio_notafiscal, :to => :produto_enviado
  end
  
  # Insere no pedido o codigo de postagem 
  event :incluir_cod_postagem do
    transitions :from => :produto_enviado,              :to => :produto_enviado_cod_postagem
  end
  
  # CLIENTE notifica que recebeu produto
  event :cliente_recebeu do
    transitions :from => :produto_enviado_cod_postagem, :to => :recebido_pelo_cliente
  end
  
  # Cancelar pedido
  event :cancelar do
    transitions :from => :aguardando_pagamento,         :to => :pedido_cancelado
    transitions :from => :processando_envio,            :to => :pedido_cancelado
  end
  
  # Encerrar pedido
  event :encerrar do
    #transitions :from => :aguardando_pagamento,        :to => :encerrado
    transitions :from => :processando_envio,            :to => :encerrado
    transitions :from => :processando_envio_envelopado, :to => :encerrado
    transitions :from => :processando_envio_notafiscal, :to => :encerrado
    transitions :from => :produto_enviado,              :to => :encerrado
    transitions :from => :produto_enviado_cod_postagem, :to => :encerrado
    transitions :from => :recebido_pelo_cliente,        :to => :encerrado
  end
  
  # Reenviar pedido
  event :reenviar do
    transitions :from => :produto_enviado,              :to => :processando_envio, :guard => Proc.new {|o| o.pago_e_pode_reenviar? }
    transitions :from => :produto_enviado_cod_postagem, :to => :processando_envio, :guard => Proc.new {|o| o.pago_e_pode_reenviar? }
    transitions :from => :recebido_pelo_cliente,        :to => :processando_envio, :guard => Proc.new {|o| o.pago_e_pode_reenviar? }
    transitions :from => :encerrado,                    :to => :processando_envio, :guard => Proc.new {|o| o.pago_e_pode_reenviar? }
  end

  # Métodos usados pelos EVENTOS
  #=============================
  
  # Marca quando o pedido foi submetido.
  def inicia_pedido
    self.data_pedido = self.updated_at #Time.now.utc
    self.save(false)
  end

  # Marca quando o pedido foi pago.
  def pedido_pago
    self.data_pgmto = self.updated_at #Time.now.utc
    self.save(false)
    self.notifica_recebimento_pagamento
  end

  # Avisa que o produto já está no
  # envelope e indo para o correio.
  def pedido_envelopado
    self.notifica_pedido_envelopado
    # salvo a data/hora da impressao 
    # para usar dentro da nota fiscal
    self.data_nf = Time.now.utc
    self.save(false)
  end

  # Marca a hora da impressao da NF.
  def pedido_notafiscal
    #self.data_nf = Time.now.utc
    #self.save(false)
  end

  # 1. Dá baixa no estoque dos produtos enviados.
  # 2. Notifica o cliente da postagem dos produtos.
  def envia_produto
    self.baixa_no_estoque
    # Marca dia/hora do envio
    self.data_envio = Time.now.utc
    self.save(false)
    # Email para cliente
    self.notifica_envio_produto
  end
  
  # Notifica o cliente o codigo de postagem do produto
  def insere_cod_postagem
    self.notifica_codigo_postagem
  end

  # Decrementa do estoque a quantidade
  # disponível do produto.
  def baixa_no_estoque
    for p in produtos_quantidades
      produto = p.produto
      produto.qtd_estoque -= p.qtd
      produto.save(false)
    end
  end
  
  # Marca data de recebimento, agradece o feedback
  # e avisa o administrador dos comentários
  def depois_de_recebido
    self.data_recebimento = Time.now.utc
    self.save(false)
    # Agradece o feedback
    self.obrigado_pela_compra
  end
  
  # Incrementa o Reenvio e retorna TRUE
  # para mudar de estado no ACTS_as_state...
  def pago_e_pode_reenviar?
    if self.recebido_pelo_cliente?
      return false # como reenviar se o cliente já recebeu??
    else
      self.reenvio += 1
      self.reenviado = true
      self.reenviado_em = Time.now.utc
      self.save(false)
      return true
    end
  end

  #============================================================================#
  #                            EMAIL  NOTIFICATIONS                            #
  #============================================================================#
  
  # Envia email ao cliente dizendo:
  # 1. Recebemos o pedido X...
  # 2. Aguardamos o pagamento...
  def notifica_recebimento_pedido
    Mailer.deliver_recebemos_seu_pedido(self)
  end
  
  # Envia email ao cliente dizendo:
  # 1. Recebemos o pagamento do pedido X
  # 2. Seu produto será enviado o mais breve..
  def notifica_recebimento_pagamento
    Mailer.deliver_confirmamos_seu_pagamento(self) unless self.reenviado
  end
  
  # Envia email ao cliente dizendo:
  # 1. Seu produto já foi embalado
  # 2. Será encaminhado ao correio ainda hoje.
  def notifica_pedido_envelopado
    Mailer.deliver_produto_envelopado(self) unless self.reenviado
  end
  
  # Envia email ao cliente dizendo:
  # 1. Produto enviado pelo Correio, 
  #    identificação X, deve chegar em Y dias.
  # 2. Ao receber seu produto, por favor
  #    notifique-nos no link abaixo...
  def notifica_envio_produto
    Mailer.deliver_enviamos_seu_produto(self)
  end
  
  # Envia email ao cliente dizendo:
  # O código de postagem de seu produto é...!
  def notifica_codigo_postagem
    Mailer.deliver_codigo_postagem(self)
  end
  
  # Agradece tudo ao cliente
  def obrigado_pela_compra
    Mailer.deliver_obrigado_pelo_feedback(self) unless self.reenviado
  end
  
  # Envia o feedback do pedido ao admin
  def notifica_ao_admin_feedback
    Mailer.deliver_admin_feedback_cliente(self) if self.obs and not self.obs.empty?
  end
  
  # Envia email ao cliente dizendo:
  # 1. Pedido X foi cancelado por isso, aquilo etc.
  def notifica_cancelamento
    Mailer.deliver_pedido_cancelado(self)
  end
  
  def notifica_encerramento
  end
  
  # Envia email ao cliente dizendo:
  # Seu boleto não foi pago, tente pagá-lo a tempo!
  def notifica_retry_boleto
    Mailer.deliver_retry_boleto(self)
  end
end