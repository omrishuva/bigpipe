class SiteText < Entity
	attr_accessor :id, :name, :locale, :compressed_text, :created_at, :updated_at, :created_by, :updated_by
	
	def text
		Zlib::Inflate.inflate(Base64.decode64(compressed_text)) if compressed_text.present?
	end
	
	def generate_key
		"#{I18n.locale}_trip_request"
	end

	def namespace
		"super_admin"
	end
end