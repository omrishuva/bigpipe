class Activity < Entity
  
  DEPRECATED_FIELDS = [:location_coordinates]

	attr_accessor :id, :user_id ,:title, :locale, :gender, :cover_image_id, :about_text, :location, :place_id, :categories, :tags, :levels, :created_by, :owner_id, :created_at, :updated_at

	def self.create( params )
    self.new(params).save
  end

  def initialize( params = { } )
  	super( params )
  end
  
  def owners
  	[user_id, owner_id ].uniq.compact
  end

  def user
    @user ||= User.find(user_id)
  end

  def cover_image
    cover_image_id || "http://placehold.it/700x400"
  end

end