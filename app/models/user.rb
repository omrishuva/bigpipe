class User < Entity

	attr_accessor :id, :first_name, :last_name, :email, :phone, :company_name, :account_name, :role, :created_at, :updated_at
	attr_reader :password_salt, :password_hash

  include BCrypt
	 	
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :phone, presence: true
  validates :password_hash, presence: true
  validates :email, :format => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
  validate :uniqueness_of_email
  validate :uniqueness_of_phone
  validates :phone, :exact_length => 10

  def initialize( params = { } )
  	if !params[:password].blank?
	  	self.password_salt = BCrypt::Engine.generate_salt
	  	self.password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
  	end
		params.delete(:password)
  	super( params )
  end

  def name
  	"#{self.first_name} #{self.last_name}"
  end
  
  def customize_error_messages
  	if errors[:password_hash]
	  	errors.delete(:password_hash)
	  	errors.add(:password, "is missing")
		end
	  errors[:phone] = ["number is not valid"] if errors[:phone] == ["is not 10 characters"]
  end
  
  def uniqueness_of_email(entity)
  	if !entity.persisted?
  		if User.find_by( :email, entity.email ).present?
  			errors.add(:email, "adress already exists")
  		end
  	end
  end

  def uniqueness_of_phone(entity)
  	if !entity.persisted? 
  		if User.find_by( :phone, entity.phone ).present?
  			errors.add(:phone, "number already exists")
  		end
  	end
  end

  class << self
	
	  def authenticate(email, password)
	    user = find_by(:email, email)
	    if user && user.password_hash == BCrypt::Engine.hash_secret(password, user.password_salt)
	      user
	    else
	      nil
	    end
	  end
	
	  def create(params)
  		self.new(params).save
  	end
	
	end
	
	protected
	attr_writer  :password_salt, :password_hash

end