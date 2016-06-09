class AppMailer < ApplicationMailer
	 
	default from: 'support@play.org.il'

	def password_recovery_code_mail(email, password_recovery_code)
		@user = user
		@password_recovery_code = rand.to_s[2..5]
		
		mail(to: email, subject: 'Play - Password Recovery')
	end

end
