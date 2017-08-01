EgovUtils::Engine.routes.draw do

  get '/login', to: 'sessions#new', as: 'signin'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'signout'

  resources :sessions
  resources :users do
    get :search, on: :collection
    post :approve, on: :member
  end

  get '/address/validate_ruian' => 'addresses#validate_ruian', as: :validate_ruian


end
