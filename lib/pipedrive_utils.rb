class PipedriveUtils
	
	def initialize
		Pipedrive.authenticate( "39079b99d1beb5e08121fb4b7c4833e50550d4c5" )
	end

	def find_person(user_id)
		Pipedrive::Person.find( user_id )
	end

end