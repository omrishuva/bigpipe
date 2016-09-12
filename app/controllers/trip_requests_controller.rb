class TripRequestsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [ :new_trip_request ]

	def new_trip_request
		@trip_request = TripRequest.new( user_id: current_user.try(:id) )
		@trip_request.save
		render js: "window.location = '/trip_request/setup/#{@trip_request.id}' "
	end
	
	def trip_request_setup
		@trip_request = TripRequest.find( params[:tripRequestId].to_i )
	end

end