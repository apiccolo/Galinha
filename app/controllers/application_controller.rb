# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :get_settings, :qual_banco
  
  # http://github.com/rails/exception_notification
  include ExceptionNotification::Notifiable #include ExceptionNotifiable

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  filter_parameter_logging :senha,
                           :senha_confirmation,
                           :senha_digitada,
                           :senha_digitada_confirmation,
                           :cartao_de_credito,
                           :chave_privada

   # Oferece autenticação, login, logout, etc.
   include Galinha::Autenticacao
   
   private
   
   def get_settings
     @settings = Settings.all
   end
   
   helper_method :ambiente_producao?
   def ambiente_producao?
     (RAILS_ENV=='production')
   end
   
   def check_access
     if ambiente_producao?
       authenticate_or_request_with_http_basic do |user_name, password|
         user_name == "galinha" && password == "pintinho-molhado"
       end
     end
   end
   
   def qual_banco
     if not ambiente_producao?
       config = Rails::Configuration.new
       tmp = ActiveRecord::Base.connection
       flash[:warning] = "Atenção: você está desenvolvendo no <b>#{tmp.adapter_name}</b>, database <b>#{config.database_configuration[RAILS_ENV]['database']}</b>"
     end
   end
   
end
