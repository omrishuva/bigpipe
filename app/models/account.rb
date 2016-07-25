class Account < Entity

	attr_accessor :id, :name, :logo, :updated_at, :created_at

	def self.namespace
		"master_#{Rails.env.to_s}"
	end

end