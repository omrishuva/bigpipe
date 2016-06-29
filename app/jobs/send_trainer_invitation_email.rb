class SendTrainerInvitationEmail < ActiveJob::Base
  queue_as :now

  def perform( args )
  	begin
	  	AppMailer.trainer_invitation_email( args["email"], args["name"], args["invited_by"] ).deliver_now
		rescue => e
			Rails.logger.info "#{e.message} -- #{e.backrace}"
		end
	end

end