class SendPasswordRecoveryEmail < ActiveJob::Base
  queue_as :now

  def perform( args )
  	AppMailer.password_recovery_code_mail( args["email"], args["name"], args["password_recovery_code"] ).deliver_now
	end

end