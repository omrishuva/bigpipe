class Activity < Entity

	attr_accessor :id, :title, :locale, :gender, :image_ids, :about_text, :created_by, :owner, :created_at, :updated_at

	def self.create( params )
    self.new(params).save
  end

  def initialize( params = { } )
  	super( params )
  end

end