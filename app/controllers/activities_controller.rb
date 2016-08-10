class ActivitiesController < ApplicationController

	def new_activity
		if current_user && current_user.current_account_id
			activity = Activity.new( account_id: current_user.current_account.id, title: "Untitled Activity", state: "draft" )
			activity.save
		else
			account = Account.create_freelancer_account( current_user )
			activity = Activity.new( account_id: account.id, title: "Untitled Activity", state: "draft" )
			activity.save
		end
		redirect_to "/activities/#{activity.id}"
	end
	
	def activity
		@activity = Activity.find( params[:activity_id] )
		@is_widget_editor =  @activity.account.is_editor?( current_user ) 
		params[:state] = nil if params[:state] == 'edit' && !@is_widget_editor
	end

end