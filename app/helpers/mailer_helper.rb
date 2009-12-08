module MailerHelper

  # Retorna o link para feedback.
  def link_to_feedback(pedido, pessoa)
    dominio = ActionMailer::Base.smtp_settings[:domain]
    link = "http://#{dominio}/comprar/feedback?pid=#{pedido.id}&chkpid=#{pessoa.id}&md5=#{pessoa.md5}"
    return link
  end

  # Retorna o cabecalho padrao do email.
  def cabecalho
    cabecalho  = "#----------------------------------------------------------#\n"
    cabecalho += "# Email gerado automaticamente. Não responda esse email. \n"
    cabecalho += "#----------------------------------------------------------#\n"
    return cabecalho
  end

  # Retorna o rodapé padrao do email.
  def rodape
    rodape =  "#-------------------------------------------------------------#\n"
    return rodape
  end
end