class SendPasswordRecoveryEmail < ActiveJob::Base
  queue_as :now

  def perform( args )
  	Rails.logger.info 
  	begin
	  	AppMailer.password_recovery_code_mail( args["email"], args["name"], args["password_recovery_code"] ).deliver_now
	  	Rails.logger.info "Send Successfully"
		rescue => e
			Rails.logger.info "#{e.message}"
			Rails.logger.info "#{e.backrace}"
		end
	end

end