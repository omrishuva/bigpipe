Rails.application.routes.draw do

  
  root "users#index"

	post '/login' => 'sessions#create'
	get '/logout' => 'sessions#destroy'

	get 'users' => 'users#index'
	get '/signup' => 'users#new'
	post '/signup' => 'users#create'

	get '_ah/health', :to => 'application_health#health'
	get '_ah/start', :to => 'application_health#start'
	get '/_ah/background', :to => "application_health#background"

end
