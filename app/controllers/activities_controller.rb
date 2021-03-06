class ActivitiesController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [ :save_scheduling, :new_activity ]

	def activity_setup
		@activity = Activity.find( params[:activityId] ) 
	end
	
	def new_activity
		if current_user && current_user.current_account_id
			if current_user.current_account.account_type.present?
				@activity = Activity.new( account_id: current_user.current_account.id, title: "Untitled Activity" )
				@activity.save
				# redirect_to "/activity/setup/#{@activity.id}"
				render js: "window.location = '/activity/setup/#{@activity.id}' "
			else
				render js: "window.location = '/account/setup/#{current_user.current_account_id}'"
			end
		else
			account = Account.create_freelancer_account( current_user )
			render js: "window.location = '/account/setup/#{account.id}'"
		end
	end

	def activity
		activity_id = params[:activity_id] || params[:activityId]
		@activity = Activity.find( activity_id )
		@is_widget_editor =  @activity.account.is_editor?( current_user ) 
		params[:state] = nil if params[:state] == 'edit' && !@is_widget_editor
	end

end