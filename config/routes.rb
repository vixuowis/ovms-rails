Ovms::Application.routes.draw do
  
  get "oval/index"
  root :to => 'home#index'
  get '/index' =>'home#index2'
  match '/database' ,to: 'vulndb#index' ,via:'get'
  match '/oval' ,to: 'oval#index' ,via:'get'
  match '/stream' ,to: 'stream#index' ,via:'get'
  match '/calendar' ,to: 'calendar#index' ,via:'get'
  match '/getcalendar' ,to: 'calendar#getcalendar' ,via:'get'
  match '/scan' ,to: 'scan#index' ,via:'get'
  match '/predict' ,to: 'predict#index' ,via:'get'
  match '/log' ,to: 'log#index' ,via:'get'
  match '/setting' ,to: 'setting#index' ,via:'get'

  match '/learning', to:'predict#learning_caller', via:'get'
  match '/sync_vuln', to:'vulndb#sync_vuln', via:'get'
  match '/sync_oval', to:'oval#sync_oval', via:'get'
  match '/scan_client', to:'scan#scan_client', via:'get'

  match '/add_client', to:'scan#add_client', via:'get'
  match '/edit_client', to:'scan#edit_client', via:'get'
  match '/delete_client', to:'scan#delete_client', via:'get'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
