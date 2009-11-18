class Admin::AcessoController < ApplicationController
  layout "admin/login"

  def login
    if request.post?
      if administrador = Administrador.autenticar(params[:email], params[:senha])
        logar_admin(administrador)
        redirect_back_or_default :controller => "admin/cartoes", :action => "index"
      else
        flash.now[:warning] = "O e-mail e a senha não correspondem."
      end
    end
  end

  def logout
    deslogar_admin
    redirect_to root_url
  end
end