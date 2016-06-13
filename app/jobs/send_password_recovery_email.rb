class SendPasswordRecoveryEmail < ActiveJob::Base
  queue_as :now

  def perform( args )
  	Rails.logger.info 
  	begin
  		Rails.logger.info "Sending Email"
	  	AppMailer.password_recovery_code_mail( args["email"], args["name"], args["password_recovery_code"] ).deliver_now
	  	Rails.logger.info "Sent Successfully"
		rescue => e
			Rails.logger.info "==================================="
			Rails.logger.info "#{e.message}"
			Rails.logger.info "-----------------------------------"
			Rails.logger.info "#{e.backrace}"
			Rails.logger.info "==================================="
		end
	end

end