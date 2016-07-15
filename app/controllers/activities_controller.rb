class ActivitiesController < ApplicationController
	
	def new_activity
		redirect_to root_url and return unless params[:user_id] != current_user.id
		activity = Activity.new( user_id: current_user.id, title: "Untitled Activity" )
		activity.save
		redirect_to "/activities/#{activity.id}"
	end

	def activity
		@activity = Activity.find( params[:activity_id] )
	end

end