# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  before_filter :check_access
  
  include ExceptionNotifiable

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
   
   def check_access
     if (RAILS_ENV == "production")
       authenticate_or_request_with_http_basic do |user_name, password|
         user_name == "galinha" && password == "pintinho-molhado"
       end
     end
   end
   
end
