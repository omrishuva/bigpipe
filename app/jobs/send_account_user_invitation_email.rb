class SendAccountUserInvitationEmail < ActiveJob::Base
  queue_as :now

  def perform( args )
  	begin
  		Rails.logger.info "Sending Email"
	  	AppMailer.account_user_invitation_email( args["user_id"], args["email"], args["name"], args["invited_by"] ).deliver_now
		rescue => e
			Rails.logger.info "#{e.message} -- #{e.backtrace}"
		end
	end

end