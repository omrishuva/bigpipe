class ActivitiesController < ApplicationController
	
	def new_activity
		activity = Activity.new( user_id: params[:user_id], title: "Untitled Activity" )
		activity.save
		redirect_to "/activities/#{activity.id}"
	end

	def activity
		@activity = Activity.find( params[:activity_id] )
		@is_widget_owner = @activity.user_id.to_s == current_user.try(:id).to_s
		params[:state] = nil if params[:state] == 'edit' && !@is_widget_owner
	end

end