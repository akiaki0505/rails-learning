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

  #get '/stressNavi/survey', to: 'stress_navi/surveys#survey', as: 'survey'
  #get '/stressNavi/survey', to: 'stress_navi/surveys#new', as: 'new'
  #get '/stressNavi/survey/complete', to: 'stress_navi/surveys#complete', as: 'complete'

  namespace :stress_navi do
    resources :surveys, only: [:new, :create] do
      collection do
        get :new, path: ""
        get :complete
      end
    end
    resources :users, only: [:new, :create]
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"
  end

  #resources :users, only: [:index]

end