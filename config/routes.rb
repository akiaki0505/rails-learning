Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end
  post "/graphql", to: "graphql#execute"
  #root "pages#home"
  #get 'world/index'
  #get 'pages/hello'
  
  #resources :todo
  #get '/todo', to: 'todo#index'
  #post '/todo/show', to: 'todo#show', as: 'show'
  #post '/todo/show', to: 'todo#show_post', as: 'show_post'
  
  # root "todos#new"
  # resources :todos, only: [:new, :create] do
  #   collection do
  #     post 'confirm'
  #     post 'back'
  #     get 'complete'
  #   end
  # end

  #get '/stressNavi/survey', to: 'stress_navi/surveys#survey', as: 'survey'
  #get '/stressNavi/survey', to: 'stress_navi/surveys#new', as: 'new'
  #get '/stressNavi/survey/complete', to: 'stress_navi/surveys#complete', as: 'complete'

  root "stress_navi/sessions#new"
  namespace :stress_navi do
    resources :surveys, only: [:create] do
      collection do
        get :complete
        get ":user_id", to: "surveys#new", as: :new_with_user, constraints: { user_id: /\d+/ }
        get "/", to: "surveys#new", as: :new
      end
    end
    resources :employees do
      collection do
        get :csv_upload
        post :import_csv
        get  :mapping
        post :finalize_import
        get :download_format
      end
    end
    get "login", to: "sessions#new"
    post "login", to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    get "dashboard", to: "dashboard#dashboard"

    resources :users

    #get "user/list", to: "users#index"
    #get "user/destroy", to: "users#destroy"
    #機能を絞り対時に使う
    #resources :users, only: [:show, :new, :create, :edit, :update, :destroy] do
    #end

    #get "headquarter/list", to: "headquarter#index"
    resources :headquarters, only: [:index, :new, :edit]

    get 'reports', to: 'reports#index'
    post 'reports/analyze', to: 'reports#analyze'
  end

  #resources :users, only: [:index]

end