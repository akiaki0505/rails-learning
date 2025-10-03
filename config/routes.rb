Rails.application.routes.draw do
  root "pages#home"
  get 'world/index'
  get 'pages/hello'
  
  #resources :todo
  get '/todo', to: 'todo#index'
  get '/todo/show', to: 'todo#show', as: 'show'

  resources :users, only: [:index]

end