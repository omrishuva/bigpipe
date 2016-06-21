module PipedriveUtils
	
	def create_pipedrive_person
		pd_person = Pipedrive::Person.create( 
																					name: name,
																					email: email, 
																					phone: phone, 
																					"7de30fadfac146c67755fcf834dd0b98fab371c9" => media_source, 
																					"9bc9473d156cbe92893496b75242720006477913" => campaign  
																				)
		update( pipedrive_id: pd_person.id )
	end

	def create_pipedrive_lead_deal
		pd_person = create_pipedrive_person
		Pipedrive::Deal.create( title: name, person_id: pd_person.id, pipeline_id: pipeline( :lead_ads ) )
	end
	
	def pipeline( pipeline_name )
		{ lead_ads: 1, churned: 2, test: 3 }[pipeline_name]
	end


	def find_person(user_id)
		Pipedrive::Person.find( user_id )
	end

end