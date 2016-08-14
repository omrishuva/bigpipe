class AppMailer < ApplicationMailer
	 
	default from: 'care@activity.market'
	
	def password_recovery_code_mail( email, name, password_recovery_code )
		@user_name = name
		@password_recovery_code = password_recovery_code
		mail(to: email, subject: 'Activity Market - Password Recovery')
	end

	def account_user_invitation_email( args )
		@onboarding_code = args["onboarding_code"]
		@invitee_name = args["invitee_name"]
		@invitee_id = args["invitee_id"]
		@inviter_name = args["inviter_name"]
		@inviter_account_id = args["inviter_account_id"]
		@inviter_account_name = args["inviter_account_name"]
		@exists = args["exists"]
		mail(to: args["invitee_email"], subject: 'Welcome To Activity.Market')
	end

end