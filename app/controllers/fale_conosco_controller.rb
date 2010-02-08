class FaleConoscoController < ApplicationController
  layout "default"
  
  def index
    if request.post?
      Mailer.deliver_admin_fale_conosco(params) #NOTIFICAR!
      flash[:notice] = "Mensagem enviada com sucesso!"
    end
  end
  
  def quem_somos
  end
  
  def iphone
  end
    
end
