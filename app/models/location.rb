class Location < Entity

	def self.create( params )
    self.new(params).save
  end

  def initialize( params = { } )
  	super( params )
  end

end