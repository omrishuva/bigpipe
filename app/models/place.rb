class Place < Entity
	attr_accessor :id, :place_id, :place_key, :owner_object_type, :owner_object_id, :created_at, :updated_at	
	
	def self.find_by_owner_and_key( owner_object_type, owner_object_id, key )
		self.find_by(
									[
										{ k: "owner_object_type" ,v: owner_object_type ,op: "=" },
										{ k: "owner_object_id", v: owner_object_id ,op: "=" },
										{ k: "place_key" ,v: key ,op: "=" }
									]
								)
	end

end