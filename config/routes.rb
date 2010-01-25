ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  map.admin "admin", :controller => "admin/painel", :action => "index"
  map.admin_login "admin/login", :controller => "admin/acesso", :action => "login"
  map.admin_logout "admin/logout", :controller => "admin/acesso", :action => "logout"
  map.namespace :admin do |admin|
    admin.resources :administradores
    admin.resources :produtos, :collection => { :new_combo => :get,
                                                :create_combo => :post,
                                                :print => :get },
                               :member => { :edit_combo => :get,
                                            :update_combo => :put,
                                            :relacionar => :get,
                                            #:gravar_relacionar => :post,
                                            :remover_relacionar => :get,
                                            :print => :get }
    admin.resources :pedidos, :collection => { :print => :get,
                                               :lista_ceps => :get,
                                               :controle_postagem => :get },
                              :member => { :print => :get }
    
    admin.resources :descontos
    admin.resources :configuracoes, :collection => { :editar_arquivo => :post,
                                                     :salvar_arquivo => :post,
                                                     :salvar => :post,
                                                     :frete_por_estado => :get,
                                                     :frete_por_estado_salvar => :post,
                                                     :frete_por_estado_incluir_row => :post }
    admin.resources :relatorios
    admin.resources :automacoes, :collection => { :entrar_arquivo => :get,
                                                  :processar_dados => :post,
                                                  :relatorios => :get },
                                 :member => { :confirmar_pagamento => :post }
  end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => 'videos'

  # See how all your routes lay out with "rake routes"
  map.connect '/videos/:action', :controller => 'videos'

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
