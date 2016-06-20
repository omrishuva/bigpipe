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
	get '/send_password_recovery_email' => 'users#password_recovery_email'
	get '/select_new_password' => 'users#select_new_password'
	post '/set_new_password' => 'users#set_new_password'
	get '/resend_phone_number' => 'users#resend_phone_number'
	get '/change_locale' => 'users#change_locale'
	get '/crm' => 'users#crm'
	get 'pipedrive' => 'users#pipedrive'
	post 'pipedrive' => 'users#pipedrive'

	#health checks
	get '_ah/health', :to => 'application_health#health'
	get '_ah/start', :to => 'application_health#start'
	get '/_ah/background', :to => "application_health#background"

end
