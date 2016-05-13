Rails.application.routes.draw do

  
  root "sessions#new"

	get '/login' => 'sessions#new'
	post '/login' => 'sessions#create'
	get '/logout' => 'sessions#destroy'

	get '/signup' => 'users#new'
	post '/users' => 'users#create'

	get '_ah/health', :to => 'application_health#health'
	get '_ah/start', :to => 'application_health#start'
	get '/_ah/background', :to => "application_health#background"

end
