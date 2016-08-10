class Account < Entity

	attr_accessor :id, :account_type, :name, :logo, :about, :owner_ids, :editor_ids, :user_ids, :updated_at, :created_at

	def self.create_freelancer_account( user )
		account = Account.new(  account_type: "freelancer", name: user.name, owner_ids: [user.id] )
		account.save
		user.add_linked_account( account.id )
		user.switch_current_account( account.id )
		account
	end

	def upgrade_to_bussiness_account
		self.update( account_type: "business", logo: freelancer_account_owner.cover_image, about: freelancer_account_owner.about_text  )
	end
	
	def freelancer_account_owner
		@freelancer_account_owner ||= User.find( owner_ids.first.to_i )
	end

	def owners_and_editors
		@owners_and_editors ||= [owner_ids, editor_ids].flatten.uniq.compact.map(&:to_s)
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
	
	def all_members
		@all_members ||= all_members_query
	end
	
	def all_members_query
		members_data = {  owners: [], editors: [], users: []  }
		users = User.where([{ k: "linked_account_ids", v: id, op: "=" }])
		users.each do |user|
			if user_ids.present? && user_ids.include?( user.id )
				members_data[:users] << user 
			elsif editor_ids.present? && editor_ids.include?( user.id )
				members_data[:editors] << user
			elsif owner_ids.present? && owner_ids.include?( user.id )
				members_data[:owners] << user
			end
		end
		members_data
	end
	
	def owners
		all_members[:owners]
	end
	
	def editors
		all_members[:editors]
	end
	
	def users
		all_members[:users]
	end

	def add_owner( user )
		self.update( owner_ids: [ owner_ids, user.id ].flatten.compact )
	end

	def add_editor( user )
		self.update( editor_ids: [ editor_ids, user.id ].flatten.compact )
	end
	
	def add_user( user )
		self.update( user_ids: [ user_ids, user.id ].flatten.compact )
	end
	
	def is_editor?( user )
		owners_and_editors.include?( user.try(:id).to_s ) || user.try(:super_admin?)
	end
	
	def freelancer
		return nil if is_business?
		@freelancer ||= User.find( owner_ids.first.to_i )
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