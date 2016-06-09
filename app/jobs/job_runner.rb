class JobRunner
	
	attr_accessor :args

	def initialize( attributes  )
		@args = attributes
		send( args["job_name"] )
	end
	
	def send_password_recovery_email
		$stderr.puts AppMailer.password_recovery_code_mail( args["email"], args["name"], args["password_recovery_code"] ).deliver_now
	end
	

end

