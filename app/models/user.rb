class User < Entity

  DEFAULT_SERVICE = []
  DEPRECATED_FIELDS = [:service_provider_type, :service_ids ,:role, :trainer_certificate_url]

	attr_accessor :id, :pipedrive_id, :fb_id, :name, :email, :phone, :locale, :gender, :birthdate, 
  :media_source, :campaign, :phone_verification_code, :password_recovery_code, :onboarding_code, :phone_verified, 
  :profile_picture, :cover_image_cloudinary_id, :about_text, :auth_provider, :invited_by, 
  :current_account_id, :super_admin,:created_at, :updated_at, :country
	
  attr_reader :password_salt, :password_hash

	include PipedriveUtils
  include StorageUtils
  include RoleUtils
  include LocaleUtils
  include AuthenticationUtils
  include AccountUtils

  validates :name, presence: true
  validates :email, presence: true
  validates :password_hash, presence: true, :unless => :from_facebook?
  validates :email
  validate :uniqueness_of_email
  validate :uniqueness_of_phone
  
  before_destroy :delete_related_pipedrive_records
  before_save :set_locale, unless: :has_locale?
  before_save :set_default_auth_provider, unless: :auth_provider_exists?

  def self.create( params )
    self.new(params).save
  end

  def initialize( params = { } )
    params.with_indifferent_access
	  set_password( params[:password] ) if !params[:password].blank?
		params.delete(:password)
  	super( params )
  end

  def display_name
    name.humanize
  end

  def cover_image
    cover_image_cloudinary_id || "https://placehold.it/700x400"
  end

  def save_about_text(field, data)
    self.update( about_text: params[:user_about_text] ) if params["user_about_text"].present?
  end

  def activities
    @activities ||= Activity.where( [{ k: "account_id", v: current_account_id, op: "=" }] )
  end
  
  def completed_profile_personal_info?
    cover_image_cloudinary_id.present? && about_text.present?
  end
  
	protected

	attr_writer  :password_salt, :password_hash
  
end