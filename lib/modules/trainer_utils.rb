module TrainerUtils
	
	def self.included(base)
    base.extend(TrainerClassMethods)
  end
	
	module TrainerClassMethods
		
		def new_trainer( params )
			user = User.new( params[:user].merge( role: 2, phone_verified: true, password: generate_password ) )
			user.save
			unless user.errors.present?
				user.save_certificate_file( params[:certificate].tempfile )
				SendTrainerInvitationEmail.perform_later( 
																									user_id: user.id, 
																									email: user.email, 
																									name: user.name, 
																									invited_by: user.invited_by 
																								)
			end
			user
		end
	
	end

	def save_certificate_file( temp_certificate_file )
    certificate_file = self.save_file( temp_certificate_file, "certificate_#{self.id}", "certificates", public: true )
    self.update( trainer_certificate_url: certificate_file.public_url )
  end

end