Rails.application.routes.draw do
  devise_for :cuentas, :skip => [:sessions]
  as :cuenta do
    get 'iniciarsesion', to: 'devise/sessions#new', as: :new_cuenta_session
    post 'iniciarsesion', to: 'devise/sessions#create', as: :cuenta_session
    delete 'cerrarsesion', to: 'devise/sessions#destroy', as: :destroy_cuenta_session
    
    get 'cambiarcontrasenia', to: 'mi_cuenta/contrasenia#edit', as: :cambiar_contrasenia
    patch 'cambiarcontrasenia', to: 'mi_cuenta/contrasenia#update'
    put 'cambiarcontrasenia', to: 'mi_cuenta/contrasenia#update'
  end
  
  resources :inscripciones, only: [:new, :create]
  
  get 'mostrar_categoria', to: 'inscripciones#mostrar_categoria', as: 'mostrar_categoria'
  get 'mostrar_categoria/:nil/:silla_ruedas', to: 'inscripciones#mostrar_categoria'
  get 'mostrar_categoria/:nil/:nil1/:silla_ruedas', to: 'inscripciones#mostrar_categoria'
  get 'mostrar_categoria/:dia/:mes/:anio/:silla_ruedas', to: 'inscripciones#mostrar_categoria'
  
  resources :inscritos, :contenido, :sistema, only: [:index]
  
  namespace :inscritos do
    resources :comprobantes, only: [:index,:new,:create]
  end
  namespace :contenido do
    resources :posts, :archivos, :bloques, only: [:index, :new, :create, :edit, :update]
    resources :menus, only: [:index] do
      resources :elementos, only: [:new, :create, :edit, :update]
    end
  end
  
  namespace :sistema do
    resources :cuentas, :roles, only: [:index, :new, :create, :edit, :update]
  end
  
  get 'post/:id', controller: 'inicio', action: 'post', as: :post
  
  get 'archivo/:id', controller: 'inicio', action: 'archivo', as: :archivo
  
  get 'u/:usuario', controller: 'inicio', action: 'perfil', as: :perfil
  get 'u/:usuario/pag/:pag', controller: 'inicio', action: 'perfil'
  
  get 'pag/:pag', controller: 'inicio', action: 'index', as: :index_pag
  
  get 'etiqueta/:consulta', controller: 'inicio', action: 'etiqueta', as: :etiqueta
  get 'etiqueta/:consulta/pag/:pag', controller: 'inicio', action: 'etiqueta'
  
  get '/:alias', controller: 'inicio', action: 'alias', as: :alias
  get '/:alias/pag/:pag', controller: 'inicio', action: 'alias'
  
  root 'inicio#index'
  
  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
