class Account < Entity

	attr_accessor :id, :account_type, :name, :logo, :about, :owners, :editors, :users, :updated_at, :created_at

	def self.create_freelancer_account( user )
		account = Account.new(  account_type: "freelancer", name: user.name, owners: [user.id] )
		account.save
		user.add_linked_account( account.id )
		user.switch_current_account( account.id )
		account
	end

	def upgrade_to_bussiness_account
		self.update( account_type: "business", logo: freelancer_account_owner.cover_image, about: freelancer_account_owner.about_text  )
	end
	
	def freelancer_account_owner
		@freelancer_account_owner ||= User.find( owners.first.to_i )
	end

	def owners_and_editors
		@owners_and_editors ||= [owners, editors].flatten.uniq.compact.map(&:to_s)
	end
	
	def add_account_user( user, role )
		case role
		when "seller_account_owner"
			add_owner( user )
		when "seller_account_editor"
			add_editor( user )
		when "seller_account_user"
			add_user( user )
		end
	end

	def add_owner( user )
		self.update( owners: [ owners, user.id ].flatten.compact )
	end

	def add_editor( user )
		self.update( editors: [ editors, user.id ].flatten.compact )
	end
	
	def add_user( user )
		self.update( users: [ users, user.id ].flatten.compact )
	end
	
	def is_editor?( user )
		owners_and_editors.include?( user.try(:id).to_s ) || user.try(:super_admin?)
	end
	
	def freelancer
		return nil if is_business?
		@freelancer ||= User.find( owners.first.to_i )
	end
	
	def public_info
		@public_info ||= { text: freelancer.about_text, image: freelancer.cover_image_cloudinary_id } if is_freelancer?
		@public_info ||= { text: self.about, image: self.logo } if is_business?
		@public_info
	end

	def is_freelancer?
		account_type == "freelancer"
	end

	def is_business?
		account_type == "business"
	end

end