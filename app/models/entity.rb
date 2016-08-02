# encoding: UTF-8
class Entity
  	
	include ActiveModel::Model
	extend ActiveModel::Callbacks
	
	include Veto.validator

	Veto.configure do |c|
		c.message.set(:presence, lambda{ "is_missing" } )
		c.message.set(:format, lambda{ "wrong_format" } )
	end

	define_model_callbacks :save, :create, :update, :initialize, :destroy
	
	DEPRECATED_FIELDS = []

	def save
		run_callbacks :save do
	    self.created_at = Time.now unless persisted?
	    if valid? self
	      entity = to_entity
	      entity.key.namespace = self.class.namespace
	      entity["updated_at"] = Time.now
	      $datastore.save entity
	      self.id = entity.key.id
	      true
	    else
	    	customize_error_messages
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
  	run_callbacks :destroy do
	    $datastore.delete(  set_key_properties( $datastore.entity ) )
  	end
  end
 
  def persisted?(user="user")
    id.present?
  end
  
  def set_key_properties(entity)
  	entity.key.kind = self.class.name
  	entity.key.namespace = self.class.namespace
  	entity.key.id = self.id.to_i if self.id
  	entity
  end

  def to_entity
    entity = set_key_properties( $datastore.entity )
    self.class.get_attributes.each do |attribute|
    	if self.send(attribute)
    		if self.send(attribute).class == String
	    		entity[attribute.encode("UTF-8")] = self.send(attribute).encode("UTF-8")
    		else
    			entity[attribute] = self.send(attribute) if self.send(attribute)
    		end
    	end
    end
    entity
  end
  
  def customize_error_messages
  end
  
  def owners
  	[id]
  end
  
  def upload_image( image_file, image_field, cropping_params = nil )
  	default_cropping_params = { width: 700, height: 400, crop: :thumb, gravity: :face }
  	cropping_params = cropping_params || default_cropping_params
  	cloudinary_image = Cloudinary::Uploader.upload( image_file, eager: cropping_params )
  	Cloudinary::Uploader.destroy( self.send( image_field ) ) if self.send( image_field ).present?
  	self.update( image_field => cloudinary_image["public_id"] )
  end
  
  def reload!
  	self.class.find( self.id )
  end

	class << self
		
		def namespace
			Rails.env.to_s
		end

		def from_entity( entity )
	    if entity
		    object = self.new
		    object.id = entity.key.id
		    entity.properties.to_hash.each do |name, value|
		      begin
		      	binding.pry
			      object.send( "#{name}=", value)
					rescue => e
						raise e unless remove_deprecated_fields( entity, name )
					end
		    end
	    	object
	  	else
	  		nil
	  	end
	  end
		
		def remove_deprecated_fields( entity, field )
			if self.class::DEPRECATED_FIELDS && self.class::DEPRECATED_FIELDS.include?( field.to_sym )
				entity.properties.delete( field )
			else
				false
			end
		end

	  def find( id )
	    key = $datastore.entity.key
	    key.kind = self.name; key.namespace = self.namespace; key.id = id.to_i
	    entity = $datastore.find key
	    from_entity( entity ) if entity
	  end
	  
	  def find_by( query_params ) #returns one result
	  	where(query_params)[0]
	  end

	  def where( query_params )
	  	query_obj = $datastore.query.kind(self.name)
	  	query_params.each do |filter|
	  		query_obj = query_obj.where( filter[:k].to_s, filter[:op], filter[:v] )
	  	end
	  	run_query(query_obj).map{ |ent| from_entity(ent)  }	
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

		def run_query( query_obj )
			$datastore.run( query_obj, namespace: self.namespace )
		end

		def new_entity( properties = { } )
			entity = $datastore.entity self.name do |e|
											properties.each do |k,v|
												e[k.to_s] = v
											end
											e.key.namespace = self.namespace
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