class Activity < Entity

	attr_accessor :id, :user_id ,:title, :locale, :gender, :image_ids, :about_text, :created_by, :owner_id, :created_at, :updated_at

	def self.create( params )
    self.new(params).save
  end

  def initialize( params = { } )
  	super( params )
  end
  
  def owners
  	[user_id, owner_id ].uniq.compact
  end

end