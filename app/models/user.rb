class User < Entity

  DEFAULT_ROLE = 3

	attr_accessor :id, :pipedrive_id, :fb_id, :name, :email, :phone, :locale, :gender, :birthdate, 
  :media_source, :campaign, :phone_verification_code, :password_recovery_code, :phone_verified, 
  :profile_picture, :auth_provider, :role, :service_provider_type, :trainer_certificate_url, :invited_by, 
  :created_at, :updated_at
	
  attr_reader :password_salt, :password_hash

	include PipedriveUtils
  include StorageUtils
  include RoleUtils
  include AuthenticationUtils
  include TrainerUtils

  validates :name, presence: true
  validates :email, presence: true
  validates :password_hash, presence: true, :unless => :from_facebook?
  validates :email, :format => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validate :uniqueness_of_email
  validate :uniqueness_of_phone
  
  before_destroy :delete_related_pipedrive_records
  before_save :set_default_role, unless: :has_role?
  before_save :set_locale, unless: :has_locale?

  def self.create( params )
    self.new(params).save
  end

  def initialize( params = { } )
    params.with_indifferent_access
	  set_password( params[:password] ) if !params[:password].blank?
		params.delete(:password)
  	super( params )
  end
    
	protected

	attr_writer  :password_salt, :password_hash
  
end