module AccountUtils
	
	def self.included(base)
    base.extend(AccountClassMethods)
  end	
	
	module AccountClassMethods
	
		def new_account_user( params, account )
			if user = User.find_by([{ k: "email", v: params[:email] ,op: "=" }])
				if user.has_linked_accounts?
					account.add_account_user( user, params[:role] )
					user.add_linked_account(account.id)
					SendAccountUserInvitationEmail.perform_later( params.merge( account_name: account.name ) )
				else
					account.add_account_user( user, params[:role] )
					user.add_linked_account(account.id)
					user.switch_current_account( account.id )
					SendAccountUserInvitationEmail.perform_later( params.merge( account_name: account.name ) )
				end
			else
				user = User.new( email: params[:email], name: params[:email], phone: params[:phone], password:  User.generate_password )
				user.save
				account.add_account_user( user, params[:role] )
				user.add_linked_account(account.id)
				user.switch_current_account( account.id )
				SendAccountUserInvitationEmail.perform_later( params.merge( account_name: account.name ) )
			end
			user
		end
		
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
		current_account.owners.map(&:to_i).include?(self.id.to_i) if current_account.owners.present?
	end	

 	def is_account_editor?
 		current_account.editors.map(&:to_i).include?(self.id.to_i) if current_account.editors.present?
 	end

 	def is_account_user?
 		current_account.users.map(&:to_i).include?(self.id.to_i) if current_account.users.present?
 	end

end