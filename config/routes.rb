Rails.application.routes.draw do

  
  root "users#index"

  #sessions
	post '/login' => 'sessions#create'
	get '/login' => 'sessions#new'
	get '/logout' => 'sessions#destroy'

	#users
	get 'users' => 'users#index'
	get '/signup' => 'users#new'
	post '/signup' => 'users#create'
	post '/authenticate_phone' => 'users#authenticate_phone'

	get '_ah/health', :to => 'application_health#health'
	get '_ah/start', :to => 'application_health#start'
	get '/_ah/background', :to => "application_health#background"

end
