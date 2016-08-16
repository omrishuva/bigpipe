class Activity < Entity
  
  DEPRECATED_FIELDS = [:location_coordinates, :user_id]

	attr_accessor :id, :state, :account_id, :title, :locale, :gender, :cover_image_id, :about_text, :location, :place_id, :categories, :tags, :levels, :created_by, :owner_id, :created_at, :updated_at

	def self.create( params )
    self.new(params).save
  end

  def initialize( params = { } )
  	super( params )
  end
  
  def owners
  	[user_id, owner_id ].uniq.compact
  end

  def cover_image
    cover_image_id || "https://placehold.it/700x400"
  end
  
  def self.metadata
    @@metadata =  YAML.load_file("./lib/activity_metadata.yaml")
  end
  
  def account
    @account ||= Account.find( account_id.to_s )
  end

  def account_public_info_completed?
    ![account.public_info[:text].present?, account.public_info[:image].present?].uniq.include?( false )
  end

end