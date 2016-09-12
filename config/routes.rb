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
	get  '/join_as_expert' 																									 => 'users#join_as_expert'
	
	#invite users
	get  '/account_user/new'         				 																	=> 'users#invite_account_user'
	post '/account_user/new'         				 																	=> 'users#add_account_user'
	get  '/account/onboarding/:account_id/:user_id'								       			=> 'users#onboarding_page'
	post '/account/onboarding/:account_id/:user_id'      					 						=> 'users#onboarding_form_submit'
	get  '/account/existing_user/onboarding/:account_id/:user_id'							=> 'users#existing_user_onboarding'
	#accounts
	post '/accounts/upgrade_business/:account_id'													    => 'accounts#upgrade_to_business_account'
	get '/account/setup/:accountId'																					 	=> 'accounts#account_setup'

	#activities	
	post '/new_activity'											 										 	   				 => 'activities#new_activity'
	get '/activity/setup/:activityId'																					 => 'activities#activity_setup'
	get '/activities/:activityId' 						                             	   => 'activities#activity'
	
	#trip_request
	post '/new_trip_request'											 										 	   		 => 'trip_requests#new_trip_request'
	get '/trip_request/setup/:tripRequestId'                                   => 'trip_requests#trip_request_setup'

	#multiple state widget
	get   '/widgets/widget_control/:widgetName/:objectName/:key'               => 'widgets#widget_control'
	post  '/widgets/widget_control/:widgetName/:objectName/:key'               => 'widgets#widget_control'
	#admins
	get '/admins/site_text/create' 																						 => 'admins#create_site_text'
	get '/admins/site_text/index' 																						 => 'admins#site_text_index'
	get '/admins/site_text/edit/:id' 																				   => 'admins#edit_site_text'

	#health checks
	get '_ah/health'      																						=> 'application_health#health'
	get '_ah/start'       														 								=> 'application_health#start'
	get '/_ah/background' 														 							  => "application_health#background"


end
