class SiteText < Entity
	attr_accessor :id, :name, :locale, :compressed_text, :created_at, :updated_at, :created_by, :updated_by
	after_save :refresh_cache_key

	def text
		Zlib::Inflate.inflate(Base64.decode64(compressed_text)) if compressed_text.present?
	end
	
	def generate_key
		"#{I18n.locale}_#{name}"
	end

	def namespace
		"super_admin"
	end
	
	def refresh_cache_key
		$wizards[generate_key] = text
	end

end