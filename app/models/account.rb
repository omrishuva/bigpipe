class Account < Entity

	attr_accessor :id, :account_type, :name, :logo, :about, :updated_at, :created_at

	def self.create_freelancer_account( user )
		account = Account.new(  account_type: "freelancer", name: user.name )
		account.save
		account.assign_account_role_to_user( user, User.role_id( "seller_account_owner" ) )
		user.switch_current_account( account.id )
		account
	end

	def upgrade_to_bussiness_account
		self.update( account_type: "business", logo: freelancer_account_owner.cover_image, about: freelancer_account_owner.about_text  )
	end

	def assign_account_role_to_user( user, role_id )
		AccountRole.create( account_id: self.id, user_id: user.id, role_id: role_id )
		user.reset_linked_accounts
		reset_members
	end
	
	def freelancer_account_owner
		return nil if is_business?
		@freelancer_account_owner ||= User.find( AccountRole.find_by([{ k: "account_id", v: id, op: "=" }]).user_id )
	end
	alias freelancer freelancer_account_owner

	def member_ids
		@member_ids ||= AccountRole.where( [ { k: "account_id", v: self.id, op: "=" } ] ).map(&:user_id)
	end

	def members
		@members ||= member_ids.map{ |member_id| User.find( member_id )  }
	end
	
	def reset_members
		@members = nil
		@member_ids = nil
	end

	def owners
		@owners = members.select{ |member| member.role_id == User.role_id( "seller_account_owner" )  }
	end
	
	def editors
		@editors = members.select{ |member| member.role_id == User.role_id( "seller_account_editor" )  }
	end
	
	def is_editor?( user )
		[owners.map(&:id), editors.map(&:id)].flatten.include?( user.try(:id) ) || user.try(:super_admin?)
	end	

	def users
		@users = members.select{ |member| member.role_id == User.role_id( "seller_account_user" )  }
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