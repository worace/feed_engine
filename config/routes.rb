FeedEngine::Application.routes.draw do
  match '/dashboard' => 'dashboard#show', as: :user_root
  match '', to: 'users#show', constraints: lambda { |r| r.subdomain.present? && r.subdomain != 'www' }
  devise_for :users
  authenticated :user do
    root :to => 'dashboard#show'
  end
  devise_scope :user do
    get 'sign_in', :to => 'devise/sessions#new', :as => 'sign_in'
  end
  
  resources :posts, only: [:create, :index]
  resources :users
  resources :texts
  resources :images
  resources :links
  match '/sign_up' => 'users#new'
  
  root :to => 'pages#index'
end
