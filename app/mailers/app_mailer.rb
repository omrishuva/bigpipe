class AppMailer < ApplicationMailer
	 
	default from: 'support@play.org.il'

	def password_recovery_code_mail(user)
		@user = user
		@password_recovery_code = rand.to_s[2..5]
		@user.update(password_recovery_code: @password_recovery_code )
		mail(to: @user.email, subject: 'Play - Password Recovery',)
	end

end
