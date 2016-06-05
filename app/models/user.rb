class User < Entity

	attr_accessor :id, :name, :email, :phone, :phone_verification_code, :password_recovery_code, :phone_verified, :profile_picture, :auth_provider, :role, :created_at, :updated_at
	attr_reader :password_salt, :password_hash

  include BCrypt
	 	
  validates :name, presence: true
  validates :email, presence: true
  validates :password_hash, presence: true, :if => :from_play?
  validates :email, :format => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validate :uniqueness_of_email
  validate :uniqueness_of_phone
  
  def initialize( params = { } )
	  set_password( params[:password] ) if !params[:password].blank?
		params.delete(:password)
  	super( params )
  end
  
  def customize_error_messages
  	if errors[:password_hash]
	  	errors.delete(:password_hash)
	  	errors.add(:password, "is_missing")
		end
	  errors[:phone] = [:invalid_number] if errors[:phone] == ["is not 10 characters"]
  end
  
  def uniqueness_of_email( entity )
  	if !entity.persisted?
  		if User.find_by( :email, entity.email ).present?
  			errors.add(:email, "already_exists")
  		end
  	end
  end

  def uniqueness_of_phone( entity )
  	if !entity.persisted? 
  		if User.find_by( :phone, entity.phone ).present?
  			errors.add(:phone, :already_exists)
  		end
  	end
  end

  def from_facebook?
    auth_provider == 'facebook'
  end
  
  def from_play?( entity = nil )
    auth_provider == 'play'
  end

  def has_phone?( entity = nil )
    self.phone.present?
  end
  
  def save_phone( phone )
    update( phone: phone )
    send_and_save_phone_verification_code
  end
  
  def send_and_save_phone_verification_code
    sms =  Sms.new( "phone_verification_message", phone, { name: name } )
    sms.send_message
    update( phone_verification_code: sms.phone_verification_code  )
  end
  
  def verify_phone_number( user_verification_code )
    if user_verification_code.to_s == phone_verification_code.to_s
      update( phone_verified: true )
    else
      errors.add(:phone_verification_code, "does_not_match")
    end
  end

  class << self
	 	  
    def authenticate( params )
	    user = find_by(:email, params[:email])
      if !user && params[:auth_provider] == 'facebook'
        user = User.new(params)
        user.save
        user
      elsif user && !user.from_facebook? && params[:auth_provider] == 'facebook'
        user.update( profile_picture: params[:profile_picture], auth_provider: 'facebook' )
        user
      elsif user && user.from_facebook?
  	    user
      elsif user && user.from_play?
        if user && user.password_hash == BCrypt::Engine.hash_secret(params[:password], user.password_salt)
  	      user
  	    else
  	      nil
  	    end
      end
	  end
	
	  def create( params )
  		self.new(params).save
  	end
	 
	end
	
  def set_password( password )
    self.password_salt = BCrypt::Engine.generate_salt
    self.password_hash = BCrypt::Engine.hash_secret(password, password_salt)
  end

	protected
	attr_writer  :password_salt, :password_hash

end