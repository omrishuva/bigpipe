module AuthenticationUtils
  
  include BCrypt

  def self.included(base)
    base.extend(AuthenticationClassMethods)
  end
  
  module AuthenticationClassMethods
    
    def authenticate( params )
      user = find_by( [{ k: 'email', v: params[:email], op: "=" } ] )
      if !user && params[:auth_provider] == 'facebook'
        user = User.new(params)
        user.save
        user
      elsif user && !user.from_facebook? && params[:auth_provider] == 'facebook'
        user.update( profile_picture: params[:profile_picture], auth_provider: 'facebook' )
        user
      elsif user && user.from_facebook?
        user
      elsif user && user.from_email?
        if user && user.password_hash == BCrypt::Engine.hash_secret(params[:password], user.password_salt)
          user
        else
          nil
        end
      end
    end

    def generate_password
      SecureRandom.hex[0..8]
    end

    def phone_exists?( user )
      query_params = [ 
                        { k: "phone", v: user.phone, op: "=" }, 
                        { k: "phone_verified", v: true, op: "="  }, 
                      ]
      result = find_by( query_params )
      if result.present?
        if result.id == user.id
          false
        else
          true
        end
      else
        false
      end
    end

  end

  def customize_error_messages
  	if errors[:password_hash]
	  	errors.delete(:password_hash)
	  	errors.add(:password, "is_missing")
		end
  end
  
  def uniqueness_of_email( entity )
  	if !entity.persisted?
  		if User.find_by( [{k: "email", v: entity.email, op: "=" } ] ).present?
  			errors.add(:email, "already_exists")
  		end
  	end
  end

  def uniqueness_of_phone( entity )
  	errors.add(:phone, "already_exists") if User.phone_exists?( entity )
  end
  
  def from_facebook?( entity = nil )
    auth_provider == 'facebook'
  end
  
  def from_email?( entity = nil )
    auth_provider == 'email'
  end

  def has_phone?( entity = nil )
    self.phone.present?
  end
  
  def save_phone( phone )
    send_and_save_phone_verification_code if update( phone: phone )
  end
  
  def send_and_save_phone_verification_code
    sms =  Sms.new( "phone_verification_message", phone, { name: name } )
    update( phone_verification_code: sms.phone_verification_code  )
    sms.send_message
  end
  
  def verify_phone_number( user_verification_code )
    if user_verification_code.to_s == phone_verification_code.to_s
      update( phone_verified: true )
    else
      errors.add(:phone_verification_code, "does_not_match")
    end
  end

   def set_password( password )
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

end