class SendAccountUserInvitationEmail < ActiveJob::Base
  queue_as :now

  def perform( args )
  	begin
  		p "Sending Email"
  		p args
  		p "==================================="
	  	p AppMailer.account_user_invitation_email( args ).deliver_now
		rescue => e
			p "#{e.message} -- #{e.backtrace}"
		end
	end

end