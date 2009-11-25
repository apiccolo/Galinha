module Galinha
  module Autenticacao
#   def login_required
#     if logado?
#       return true
#     else
#       flash[:info] = "Faça o login para prosseguir."
#       guardar_url
#       redirect_to login_url
#       return false
#     end
#   end

    def admin_login_required
      if admin_logado?
        return true
      else
        flash[:info] = "Faça o login para prosseguir."
        guardar_url
        redirect_to admin_login_url
        return false
      end
    end

#    def logar_usuario(usuario)
#      session[:usuario_id] = usuario ? usuario.id : nil
#      @usuario_logado = usuario || false
#    end
#
#    def deslogar_usuario
#      session[:usuario_id] = nil
#      @usuario_logado = false
#    end

    def logar_admin(admin)
      session[:administrador_id] = admin ? admin.id : nil
      @admin_logado = admin || false
    end

    def deslogar_admin
      session[:administrador_id] = nil
      @admin_logado = false
    end

#    def usuario_logado
#      @usuario_logado = Usuario.find(session[:usuario_id]) if session[:usuario_id]
#    end

    def admin_logado
      @admin_logado = Administrador.find(session[:administrador_id]) if session[:administrador_id]
    end

#    def logado?
#      !!usuario_logado
#    end

    def admin_logado?
      !!admin_logado
    end

    def guardar_url
      session[:return_to] = request.request_uri
    end

    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default. Set an appropriately modified
    #   after_filter :store_location, :only => [:index, :new, :show, :edit]
    # for any controller you want to be bounce-backable.
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def self.included(base)
      base.send :helper_method, :admin_logado, :admin_logado? if base.respond_to? :helper_method
    end
  end
end