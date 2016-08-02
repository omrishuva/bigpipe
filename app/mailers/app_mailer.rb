class AppMailer < ApplicationMailer
	 
	default from: 'care@activity.market'
	
	def password_recovery_code_mail( email, name, password_recovery_code )
		@user_name = name
		@password_recovery_code = password_recovery_code
		mail(to: email, subject: 'Activity Market - Password Recovery')
	end

	def trainer_invitation_email( user_id, email, name, invited_by )
		@user_id = user_id
		@user_name = name
		@invited_by = invited_by
		mail(to: email, subject: 'Welcome To Activity Market')
	end

end
