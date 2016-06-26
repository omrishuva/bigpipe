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
		Pipedrive::Deal.create( title: name, person_id: pd_person.id, pipeline_id: pipeline_id[:leads], value: deal_value[campaign] )
	end
	
	def deal_value
		{ "Tennis" => 270, "Play" => 169 }
	end

	def find_person(user_id)
		Pipedrive::Person.find( user_id )
	end

	def pd_fields_api_keys
		{ media_source: "7de30fadfac146c67755fcf834dd0b98fab371c9", campaign: "9bc9473d156cbe92893496b75242720006477913" }
	end

	def pipeline_id
		{ leads: 1, churned: 2, test: 3 }
	end
	
	def pipedrive_person
		@pipedrive_person ||= Pipedrive::Person.find( pipedrive_id )
	end

	def pipedrive_deals
		@pipedrive_deals ||= pipedrive_person.deals
	end

	def delete_pipedrive_person
		Pipedrive::Person.delete( "/persons/#{pipedrive_person.id}" )
	end
	
	def delete_pipedrive_deals
		pipedrive_person.deals.each do |deal|
			Pipedrive::Deal.delete("/deals/#{deal.id}")
		end
	end

	def delete_related_pipedrive_records
		if pipedrive_id.present? && pipedrive_person.present?
			delete_pipedrive_deals
			delete_pipedrive_person
		end
	end

end