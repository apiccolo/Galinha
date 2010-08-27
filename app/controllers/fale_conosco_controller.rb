class FaleConoscoController < ApplicationController
  layout "default"
  
  skip_before_filter :verify_authenticity_token,
                     :only => :index
  def index
    if request.post?
      Mailer.deliver_admin_fale_conosco(params) #NOTIFICAR!
      flash[:notice] = "Mensagem enviada com sucesso!"
    end
  end
  
  def patrocinadores
  end
  
  def quem_somos
  end
  
  def iphone
  end
    
end
