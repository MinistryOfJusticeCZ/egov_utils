EgovUtils::Engine.routes.draw do

  get '/login', to: 'sessions#new', as: 'signin'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'signout'
  get '/signup', to: 'users#new', as: 'signup'

  resources :sessions
  resources :users do
    get :search, on: :collection
    post :approve, on: :member
    get :confirm, on: :member
  end

  resources :people

  resources :groups do
    member do
      get '/users/new', to: 'groups#new_users', as: 'new_users'
      post '/users', to: 'groups#add_users', as: 'users'
    end
  end
  resources :roles

  resources :passwords

  # post '/auth/:provider/callback', to: 'sessions#create'

  get '/address/validate_ruian' => 'addresses#validate_ruian', as: :validate_ruian
  get '/organizations/district_courts' => 'organizations#district_courts', as: :district_courts_organizations

  namespace :redmine do
    resources :issues, only: :index
  end

end
