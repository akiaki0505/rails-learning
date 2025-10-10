Rails.application.routes.draw do
  #root "pages#home"
  #get 'world/index'
  #get 'pages/hello'
  
  #resources :todo
  #get '/todo', to: 'todo#index'
  #post '/todo/show', to: 'todo#show', as: 'show'
  #post '/todo/show', to: 'todo#show_post', as: 'show_post'
  root "todos#new"
  resources :todos, only: [:new, :create] do
    collection do
      post 'confirm'
      post 'back'
      get 'complete'
    end
  end

  get '/stressNavi/survey', to: 'stress_navi/surveys#survey', as: 'survey'

  resources :users, only: [:index]

end