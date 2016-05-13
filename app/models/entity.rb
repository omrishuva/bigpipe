class Entity 
  	
	include ActiveModel::Model
	extend ActiveModel::Callbacks
	include Veto.validator

	define_model_callbacks :save, :create, :update

	def save
		run_callbacks :save do
	    self.created_at = Time.now.utc unless persisted?
	    if valid? self
	      entity = to_entity
	      entity.key.namespace = Rails.env
	      entity["updated_at"] = Time.now.utc
	      $datastore.save entity
	      self.id = entity.key.id
	      true
	    else
	      false
	    end
  	end
  end
  
  def update( attributes )
    attributes.each do |name, value|
      send("#{name}=", value) if respond_to? "#{name}="
    end
    save
  end

  def destroy
    $datastore.delete(  set_key_properties( $datastore.entity ) )
  end
 
  def persisted?(user="user")
    id.present?
  end
    
  def set_key_properties(entity)
  	entity.key.kind = self.class.name
  	entity.key.namespace = Rails.env
  	entity.key.id = self.id.to_i if self.id
  	entity
  end

  def to_entity
    entity = set_key_properties( $datastore.entity )
    self.class.get_attributes.each do |attribute|
    	entity[attribute] = self.send(attribute) if self.send(attribute)
    end
    entity
  end

	class << self
		
		def from_entity( entity )
	    object = self.new
	    object.id = entity.key.id
	    entity.properties.to_hash.each do |name, value|
	      object.send "#{name}=", value
	    end
	    object
	  end
	  
	  def find( id )
	    key = $datastore.entity.key
	    key.kind = self.name; key.namespace = Rails.env; key.id = id.to_i
	    entity = $datastore.find key
	    from_entity( entity ) if entity
	  end
	  
	  def find_by( key, value )
	  	from_entity( run_query($datastore.query.kind(self.name).where(key.to_s,"=",value))[0] )
	  end

		def all( opts = { } )
			results = run_query( $datastore.query.kind(self.name) )
			return results if opts[:raw] == true
			results.map{|entity| from_entity entity } 
		end
		
		def first(opts = { } )
			result = run_query( $datastore.query.kind(self.name).order("created_at", :asc).limit(1) )[0]
			return result if opts[:raw] == true
			from_entity( result )
		end
		
		def last(opts = { } )
			result = run_query( $datastore.query.kind(self.name).order("created_at", :desc).limit(1) )[0]
			return result if opts[:raw] == true
			from_entity( result )
		end

		def run_query( query_obj  )
			$datastore.run( query_obj, namespace: Rails.env )
		end

		def new_entity( properties = { } )
			entity = $datastore.entity self.name do |e|
											properties.each do |k,v|
												e[k.to_s] = v
											end
											e.key.namespace = Rails.env
											e["created_at"] = Time.now.utc
 									 end
			entity
		end
		
		def create( properties = { } )
			from_entity( new_entity( properties ) ).save
		end
		
		def get_attributes
			instance_methods(false).select{|a| a.to_s.include?( "=" )   }.map{|a| a.to_s.delete( "=" ) }
		end

		def destroy_all
			all.each {|e| e.destroy }
		end
	
	end
end