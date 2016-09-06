class TripRequest < Entity
	DEPRECATED_FIELDS = []
	attr_accessor :id,:user_id, :arrival_date, :place_id, :departure_date, :departure_country , :rent_car, :start_date, :end_date,
	:milestones_or_prebooking, :personal_taste_tags, :food_preferences, :special_request,
	:travel_group, :adults, :children, :seniors ,:created_at, :updated_at

	def starting_point
		Place.find_by( [
											{ k: "owner_object_type", v: self.class.name, op: "=" },
											{ k: "owner_object_id", v: self.id, op: "=" },
											{ k: "place_key", v: "starting_point", op: "=" }
									 ]
									)
	end
	
	def finish_point
		Place.find_by( [
											{ k: "owner_object_type", v: self.class.name, op: "=" },
											{ k: "owner_object_id", v: self.id, op: "=" },
											{ k: "place_key", v: "finish_point", op: "=" }
									 ]
									)
	end

end