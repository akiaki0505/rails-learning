Rails.application.routes.draw do
  root "pages#home"
  get 'world/index'
  get 'pages/hello'
  
  get "up" => "rails/health#show", as: :rails_health_check

  resources :users, only: [:index]

end