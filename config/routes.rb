Rails.application.routes.draw do

  
  root "users#home_page"

  #sessions
	post '/login'  																		 										 	 => 'sessions#create'
	get  '/login' 																		 										 	 => 'sessions#new'
	get  '/logout' 																		 										 	 => 'sessions#destroy'

	#users
	get  '/users/:role'        					 						   										 	 => 'users#users'
	get  '/signup'                  				      		 										 	 => 'users#new'
	post '/signup'                    							  										 	 => 'users#create'
	post '/authenticate_phone'       								   										 	 => 'users#authenticate_phone'
	get  '/send_password_recovery_email'							 										 	 => 'users#password_recovery_email'
	get  '/select_new_password' 											 										 	 => 'users#select_new_password'
	post '/set_new_password' 													 										 	 => 'users#set_new_password'
	get  '/resend_phone_number' 											 										 	 => 'users#resend_phone_number'
	get  '/change_locale/:locale' 										 										 	 => 'users#change_locale'
	post '/fb_lead' 																	 										 	 => 'users#fb_lead'
	get  '/me/:user_id'               							   										 	 => 'users#profile'
	get  '/profile/:user_id'            							 										 	 => 'users#profile'
	get  '/profile/navigation/:navtab'               	 										 	 => 'users#profile_navigation'
	post '/upload_image'								 							 										 	 => 'users#upload_image'
	
	#invite users
	get  '/account_user/new'         				 																	=> 'users#invite_account_user'
	post '/account_user/new'         				 																	=> 'users#invite_account_user'
	# get  '/service_provider/:account_id/onboarding'       				 						=> 'users#account_user_onboarding'
	# post '/service_provider/:account_id/onboarding'      					 						=> 'users#account_user_login'

	#accounts
	post 'accounts/upgrade_business/:account_id'													   => 'accounts#upgrade_to_business_account'

	#activities	
	get '/new_activity/:user_id'											 										 	   => 'activities#new_activity'
	get '/activities/:activity_id' 						                             	   => 'activities#activity'

	#widgets
	get   '/widgets/text_widget_control/:widgetName/:objectName/:key'              => 'widgets#text_widget_control'
	post  '/widgets/text_widget_control/:widgetName/:objectName/:key'              => 'widgets#text_widget_control'
	get   '/widgets/image_widget_control/:widgetName/:objectName/:key'             => 'widgets#image_widget_control'
	post  '/widgets/image_widget_control/:widgetName/:objectName/:key'             => 'widgets#image_widget_control'
	get   '/widgets/location_widget_control/:widgetName/:objectName/:key'          => 'widgets#location_widget_control'
	post  '/widgets/location_widget_control/:widgetName/:objectName/:key'          => 'widgets#location_widget_control'

	
	#health checks
	get '_ah/health'      																						=> 'application_health#health'
	get '_ah/start'       														 								=> 'application_health#start'
	get '/_ah/background' 														 							  => "application_health#background"


end
