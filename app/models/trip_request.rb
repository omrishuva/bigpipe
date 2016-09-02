class TripRequest < Entity
		attr_accessor :id,:user_id, :arrival_date, :place_id, :departure_date, :departure_country , :rent_car, 
		:milestones_or_prebooking, :personal_taste_tags, :food_preferences, :special_request,
		:travel_group, :adults, :children, :seniors ,:created_at, :updated_at
end