class Account < Entity
	
	def self.namespace
		"system_#{Rails.env.to_s}"
	end

end