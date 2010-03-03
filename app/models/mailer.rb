class Mailer < ActionMailer::Base
  helper :Mailer
  
  ADMIN_NOME  = "Admin Galinha Pintadinha"
  ADMIN_EMAIL = "contato@galinhapintadinha.com.br"
  
  # Emails para clientes
  #=====================

  def recebemos_seu_pedido(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @subject = "#{pedido.pessoa.primeiro_nome}, recebemos seu pedido (n.#{pedido.id})"
  end

  def confirmamos_seu_pagamento(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @subject = "Seu pagamento foi confirmado, #{pedido.pessoa.primeiro_nome}!"
  end
  
  def produto_envelopado(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @subject = "#{pedido.pessoa.primeiro_nome.camelize}, seu pedido (n.#{pedido.id}) foi embalado..."
  end
  
  def enviamos_seu_produto(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @subject = "Seu pedido foi enviado aos Correios, #{pedido.pessoa.primeiro_nome}!"
  end
  
  def codigo_postagem(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @subject = "#{pedido.pessoa.primeiro_nome.camelize}, o código de postagem de seu pedido (n.#{pedido.id}) é..."
  end
  
  def obrigado_pelo_feedback(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @subject = "Recebemos seu feedback, #{pedido.pessoa.primeiro_nome}, muito obrigado!"
  end

  def pedido_cancelado(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @subject = "#{pedido.pessoa.primeiro_nome}: pedido (n.#{pedido.id}) cancelado!"
  end
  
  def retry_boleto(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @subject = "Lembrete da Galinha Pintadinha!"
  end
  
  def novo_desconto(desconto)
    @from = "Sistema da Galinha Pintadinha <noreply@galinhapintadinha.com.br>"
    @recipients = "#{desconto.email}"
    @subject = "Desconto especial da Galinha Pintadinha!"
    @charset = "utf-8"
    @body[:desconto] = desconto
  end
  
  # Emails para administracao
  #==========================
  
  # Para debug: o q vem do PagSeguro?
  def admin_post_recebido_UOLPagSeguro(p)
    @recipients = "Me <alexandrepiccolo@gmail.com>"
    @from = "Sistema da Galinha Pintadinha <noreply@galinhapintadinha.com.br>"
    @subject = "Vars recebidas do UOLPagSeguro"
    @charset = "utf-8"
    @body[:p] = p
  end
  
  # Comentario de usuario para admins
  def admin_feedback_cliente(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @recipients = "#{ADMIN_NOME} <#{ADMIN_EMAIL}>"
    @subject = "#{pedido.pessoa.primeiro_nome} deixou comentário sobre o pedido n.#{pedido.id}"
  end
  
  # Notifica depto. financeiro sobre pgmto confirmado!
  def admin_pgmto_confirmado(pedido)
    from_to_and_others(pedido, pedido.pessoa)
    @recipients = "Financeiro GalinhaPintadinha <kellen.saviolli@gmail.com>" # #{ADMIN_EMAIL}
    @subject = "Pedido #{pedido.id}, pagamento confirmado - processar envio!"
    
    dominio = ActionMailer::Base.smtp_settings[:domain]
    @body[:link_check] = "http://#{dominio}/admin/pedidos?commit=Search&search=#{pedido.id}"
  end
  
  # Envia contato (via form fale-conosco) para admin
  def admin_fale_conosco(params)
    @from = "Sistema da Galinha Pintadinha <noreply@galinhapintadinha.com.br>"
    @recipients = "#{ADMIN_NOME} <#{ADMIN_EMAIL}>"
    #@recipients = "Alexandre <alexandrepiccolo@gmail.com>"
    @reply_to = "#{params['nome']} <#{params['email']}>"
    @subject = "Contato de #{params['nome']} via FORM fale-conosco"
    @charset = "utf-8"
    @body[:params] = params
  end
  
  # just to see lots of options...
  def generic_mail(options)
    @recipients = options[:recipients]
    @from = options[:from] || ""
    @cc = options[:cc] || ""
    @bcc = options[:bcc] || ""
    @subject = options[:subject] || ""
    @headers = options[:headers] || {}
    @charset = options[:charset] || "utf-8"
    @content_type = "multipart/alternative"
    if options.has_key? :plain_body
      part :content_type => "text/plain", :body => (options[:plain_body] || "")
    end
    if options.has_key? :html_body and !options[:html_body].blank?
      part :content_type => "text/html", :body => (options[:html_body] || "")
    end
  end
  
  private
  
  # Envio de email para pessoa dona pedido
  # Define alguns @ gerais
  def from_to_and_others(pedido, pessoa)
    @recipients = "#{pessoa.nome} <#{pessoa.email}>"
    @bcc = "#{ADMIN_NOME} <#{ADMIN_EMAIL}>"
    @from = "Sistema da Galinha Pintadinha <noreply@galinhapintadinha.com.br>"
    @charset = "utf-8"
    @body[:pedido] = pedido
    @body[:pessoa] = pedido.pessoa
    
      rodape = File.open("#{RAILS_ROOT}/app/views/mailer/_rodape.html.erb")
    @body[:rodape] = rodape.readlines
    
      dominio = ActionMailer::Base.smtp_settings[:domain]
    @body[:link2pedido]   = "http://#{dominio}/comprar/seu_pedido?pid=#{pedido.id}&pbase=#{pedido.base50}&chkpid=#{pessoa.id}&md5=#{pessoa.md5}"
    @body[:link2feedback] = "http://#{dominio}/comprar/feedback?pid=#{pedido.id}&pbase=#{pedido.base50}&chkpid=#{pessoa.id}&md5=#{pessoa.md5}"
  end
  
end
