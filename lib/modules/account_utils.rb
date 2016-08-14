module AccountUtils
		
	def new_account_user( params )
		if user = User.find_by([{ k: "email", v: params[:email] ,op: "=" }])
			if user.has_linked_accounts?
				current_account.assign_account_role_to_user( user, User.role_id( params[:role] ) )
				send_invitation_email( user, true )
			else
				current_account.assign_account_role_to_user( user, User.role_id( params[:role] ) )
				user.switch_current_account( current_account.id )
				send_invitation_email( user, true )
			end
		else
			user = User.new( email: params[:email], name: params[:name], phone: params[:phone], password:  User.generate_password )
			user.save
			current_account.assign_account_role_to_user( user, User.role_id( params[:role] ) )
			user.switch_current_account( current_account.id )
			send_invitation_email( user )
		end
		user
	end
	
	def send_invitation_email( invitee_user, exists = false )
		onboarding_code = rand.to_s[2..5]
		invitee_user.update( onboarding_code: onboarding_code )
		email_params = 	{ 
										"onboarding_code" => onboarding_code,
										"inviter_user_id" => id,
										"inviter_name" => name,
										"inviter_account_id" => current_account.id,
										"inviter_account_name" => current_account.name,
										"invitee_name" => invitee_user.name,
										"invitee_id" => invitee_user.id, 
										"invitee_email" => invitee_user.email,
										"exists" => exists
									}
		SendAccountUserInvitationEmail.perform_later( email_params )
	end

	
	def accounts_roles
		@accounts_roles ||= AccountRole.where( [{ k: "user_id", v: self.id, op: "=" }] )
	end

	def get_account_role( account_id )
		accounts_roles.select{|account_role| account_role.account_id == account_id }.first
	end

	def linked_accounts
		@linked_accounts ||= accounts_roles.map{ |account_role| Account.find( account_role.account_id ) }
	end
	
	def reset_linked_accounts
		@linked_accounts = nil
	end

	def current_account( account_id = nil )
		linked_accounts.select{|linked_account| linked_account.id == current_account_id }.first if linked_accounts.present?
	end
	
	def switch_current_account( account_id )
		@current_account = nil
		current_account( account_id )
		self.update(current_account_id: account_id )
	end

	def current_account_role
		accounts_roles.select{|account_role| account_role.account_id == self.current_account_id }.first
	end
	
	def role_id
		current_account_role.try(:role_id) || 1
	end
	
	def role_name
		User.role_name( role_id )
	end

	def account_type
		current_account.try(:account_type) if current_account_id
	end
	
	def has_linked_accounts?
		linked_accounts.present?
	end
	
	def can_edit_account?
		is_account_owner? || 
		is_account_editor? ||
		super_admin?
	end

	def is_account_owner?
		User.role_name( current_account_role.role_id ) == "seller_account_owner"
	end	

 	def is_account_editor?
 		User.role_name( current_account_role.role_id ) == "seller_account_editor"
 	end

 	def is_account_user?
 		User.role_name( current_account_role.role_id ) == "seller_account_user"
 	end

end