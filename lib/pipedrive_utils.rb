module PipedriveUtils
	
	def create_pipedrive_person
		pd_person = Pipedrive::Person.create( 
																					name: name,
																					email: email, 
																					phone: phone,
																					pd_fields_api_keys[:media_source] => media_source, 
																					pd_fields_api_keys[:campaign] => campaign  
																				)
		update( pipedrive_id: pd_person.id )
		pd_person
	end

	def create_pipedrive_lead_deal
		pd_person = create_pipedrive_person
		Pipedrive::Deal.create( title: name, person_id: pd_person.id, pipeline_id: pipeline[:lead_ads] )
	end
	
	def find_person(user_id)
		Pipedrive::Person.find( user_id )
	end

	def pd_fields_api_keys
		{ media_source: "7de30fadfac146c67755fcf834dd0b98fab371c9", campaign: "9bc9473d156cbe92893496b75242720006477913" }
	end

	def pipeline
		{ lead_ads: 1, churned: 2, test: 3 }
	end

end