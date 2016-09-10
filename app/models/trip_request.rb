class TripRequest < Entity
	DEPRECATED_FIELDS = []
	attr_accessor :id,:user_id ,:start_date, :end_date, :rent_car, :personal_taste_tags, :food_preferences, 
	:special_request, :travel_group_type, :travel_group_notes, :date_type, :approximate_month, :approximate_duration,
	 :adults, :children, :seniors ,:created_at, :updated_at

	def starting_point
		@starting_point ||= Place.find_by( [
																					{ k: "owner_object_type", v: self.class.name, op: "=" },
																					{ k: "owner_object_id", v: self.id.to_s, op: "=" },
																					{ k: "place_key", v: "starting_point", op: "=" }
																			 ]
																			)
	end
	
	def finish_point
		@finish_point ||= Place.find_by( [
																			{ k: "owner_object_type", v: self.class.name, op: "=" },
																			{ k: "owner_object_id", v: self.id.to_s, op: "=" },
																			{ k: "place_key", v: "finish_point", op: "=" }
																	 ]
																	)
	end

	def self.metadata
    @@metadata =  YAML.load_file("./lib/trip_request_metadata.yaml")
  end
  
  def generate_starting_and_ending_points
  	# Place.new( )
  end

end