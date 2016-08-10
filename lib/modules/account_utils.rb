module AccountUtils
		
	def new_account_user( params )
		if user = User.find_by([{ k: "email", v: params[:email] ,op: "=" }])
			if user.has_linked_accounts?
				current_account.add_account_user( user, params[:role] )
				user.add_linked_account( current_account.id ) 
				send_invitation_email( user )
			else
				current_account.add_account_user( user, params[:role] )
				user.add_linked_account( current_account.id )
				user.switch_current_account( current_account.id )
				send_invitation_email( user )
			end
		else
			user = User.new( email: params[:email], name: params[:name], phone: params[:phone], password:  User.generate_password )
			user.save
			current_account.add_account_user( user, params[:role] )
			user.add_linked_account(current_account.id)
			user.switch_current_account( current_account.id )
			send_invitation_email( user )
		end
		user
	end
	
	def send_invitation_email( invitee_user )
		email_params = 	{ 
										"inviter_user_id" => id,
										"inviter_name" => name,
										"inviter_account_id" => current_account.id,
										"inviter_account_name" => current_account.name,
										"invitee_name" => invitee_user.name,
										"invitee_id" => invitee_user.id, 
										"invitee_email" => invitee_user.email
									}
		SendAccountUserInvitationEmail.perform_later( email_params )
	end


	def current_account( account_id = nil )
		account_id = account_id.nil? ? self.current_account_id : account_id
		@current_account ||= Account.find( account_id )
	end
	
	def account_type
		current_account.account_type
	end

	def switch_current_account( account_id )
		@current_account = nil
		current_account( account_id )
		self.update(current_account_id: account_id, role_ids: [ 1, get_current_account_role_id ].compact )
	end
	
	def has_linked_accounts?
		self.linked_account_ids.present?
	end

	def add_linked_account( account_id )
		self.update( linked_account_ids: [linked_account_ids, account_id ].flatten.compact )
	end

	def assign_account_to_user( user, role )
		
	end

	def get_current_account_role_id
		if is_account_owner?
			User.role_id( "seller_account_owner" )
		elsif is_account_editor?
			User.role_id( "seller_account_editor" )
		elsif is_account_user?
			User.role_id( "seller_account_user" )
		end
	end

	def is_account_owner?
		current_account.owner_ids.map(&:to_i).include?(self.id.to_i) if current_account.owner_ids.present?
	end	

 	def is_account_editor?
 		current_account.editor_ids.map(&:to_i).include?(self.id.to_i) if current_account.editor_ids.present?
 	end

 	def is_account_user?
 		current_account.user_ids.map(&:to_i).include?(self.id.to_i) if current_account.user_ids.present?
 	end

end