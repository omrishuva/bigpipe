class AppMailer < ApplicationMailer
	 
	default from: 'support@play.org.il'
	
	def password_recovery_code_mail( email, name, password_recovery_code )
		@user_name = name
		@password_recovery_code = password_recovery_code
		mail(to: email, subject: 'Play - Password Recovery')
	end

end
