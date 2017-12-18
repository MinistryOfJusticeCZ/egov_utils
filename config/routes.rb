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

  resources :groups
  resources :roles

  # post '/auth/:provider/callback', to: 'sessions#create'

  get '/address/validate_ruian' => 'addresses#validate_ruian', as: :validate_ruian
  get '/organizations/district_courts' => 'organizations#district_courts', as: :district_courts_organizations


end
