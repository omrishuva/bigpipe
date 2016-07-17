class ActivitiesController < ApplicationController
	
	def new_activity
		redirect_to root_url and return unless params[:user_id] != current_user.id
		activity = Activity.new( user_id: current_user.id, title: "Untitled Activity" )
		activity.save
		redirect_to "/activities/#{activity.id}?state=edit"
	end

	def activity
		@activity = Activity.find( params[:activity_id] )
		@is_widget_owner = @activity.user_id == current_user.try(:id)
		params[:state] = nil if params[:state] == 'edit' && !@is_widget_owner
	end

end