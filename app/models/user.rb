class User < Entity

	attr_accessor :id, :pipedrive_id, :fb_id, :name, :email, :phone, :locale, :gender, :birthdate, :media_source, :campaign, 
  :phone_verification_code, :password_recovery_code, :phone_verified, :profile_picture, 
  :auth_provider, :role, :trainer_certificate_url, :invited_by, :created_at, :updated_at
	
  attr_reader :password_salt, :password_hash

  include BCrypt
	include PipedriveUtils
  include StorageUtils  

  validates :name, presence: true
  validates :email, presence: true
  validates :password_hash, presence: true, :unless => :from_facebook?
  validates :email, :format => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validate :uniqueness_of_email
  validate :uniqueness_of_phone
  
  before_destroy :delete_related_pipedrive_records
  before_save :set_default_role, unless: :has_role?
  before_save :set_locale, unless: :has_locale?

  def initialize( params = { } )
    params.with_indifferent_access
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
  
  def from_play?( entity = nil )
    auth_provider == 'play'
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
  
  def set_default_role
    self.role = 4 
  end
  
  def set_locale
    self.locale = I18n.locale.to_s
  end
  
  def has_locale?
    self.locale.present?
  end

  def save_certificate_file( temp_certificate_file )
    certificate_file = self.save_file( temp_certificate_file, "certificate_#{self.id}", "certificates", public: true )
    self.update( trainer_certificate_url: certificate_file.public_url )
  end

  def has_role?
    self.role.present?
  end
  
  def role_name
    $user_roles[self.role]
  end
  
  def admin?
    self.role == 1
  end

  class << self
	 	  
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
    
    def new_trainer( params )
      user = User.new( params[:user].merge( role: 2, phone_verified: true, password: generate_password ) )
      user.save
      unless user.errors.present?
        user.save_certificate_file( params[:certificate].tempfile )
        SendTrainerInvitationEmail.perform_later( user_id: user.id, email: user.email, name: user.name, invited_by: user.invited_by )
      end
      user
    end

	end

	protected

	attr_writer  :password_salt, :password_hash
  
end