class SendPasswordRecoveryEmail < ActiveJob::Base
  queue_as :now

  def perform( args )
  	begin
	  	AppMailer.password_recovery_code_mail( args["email"], args["name"], args["password_recovery_code"] ).deliver_now
		rescue => e
			Rails.logger.info "#{e.message} -- #{e.backrace}"
		end
	end

end