Rails.application.routes.draw do

  
  root "sessions#new"

	get '_ah/health', :to => 'application_health#health'

	get '/login' => 'sessions#new'
	post '/login' => 'sessions#create'
	get '/logout' => 'sessions#destroy'

	get '/signup' => 'users#new'
	post '/users' => 'users#create'

end
