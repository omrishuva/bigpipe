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
		activity_id = params[:activity_id] || params[:activityId]
		@activity = Activity.find( activity_id )
		@is_widget_editor =  @activity.account.is_editor?( current_user ) 
		params[:state] = nil if params[:state] == 'edit' && !@is_widget_editor
	end
	
	def select_scheduling_type
		@activity = Activity.find( params[:activityId].to_i )
		respond_to do |format|
      format.js { }
    end
	end
	
	def save_scheduling
		respond_to do |format|
      format.js { }
    end
	end

	def cancel_scheduling
		respond_to do |format|
      format.js { }
    end
	end

end