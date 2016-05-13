class User < Entity

	attr_accessor :id, :first_name, :last_name, :email, :phone, :company_name, :account_name, :role, :created_at, :updated_at
	attr_reader :password_salt, :password_hash

  include BCrypt
	 	
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true
  validates :password, presence: true, :unless => :persisted?
  # validates :password_confirmation, presence: true #unless persisted?

  def initialize( params = { } )
  	if params[:password]
	  	self.password_salt = BCrypt::Engine.generate_salt
	  	self.password_hash = BCrypt::Engine.hash_secret(params[:password], password_salt)
	  	params.delete(:password)
	  	params.delete(:password_confirmation)
  	end
  	super( params )
  end
  
  def name
  	"#{self.first_name} #{self.last_name}"
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

	end

	protected
	
	attr_writer  :password_salt, :password_hash

end