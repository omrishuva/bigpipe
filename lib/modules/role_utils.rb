module RoleUtils
  
  def self.included(base)
    base.extend(RoleClassMethods)
  end	
	
  module RoleClassMethods
    
    def default_role
      [ User.role_id( "consumer" ) ]
    end

    def default_service
      [0]
    end

    def roles_data
      $user_roles
    end

    def role_ids
      roles_data["roles"].map{|k,v| v } 
    end
    
    def roles
      roles_data["roles"].map{|k,v| k } 
    end

    def role_name( role_id )
      roles_data["roles_mapping"][role_id]
    end

    def role_id( role_name )
      roles_data["roles"][role_name]
    end

    def seller_role_short_names
      roles_data["seller_roles_short_name"]
    end

  end

  def set_default_role
    self.role_ids = self.class.default_role unless self.role_ids.present?
  end

  def has_role?
    self.role_ids.present?
  end
  
  def roles
    self.role_ids.map{ |role_id| User.role_name( role_id )  }.compact
  end
  
  def super_admin?
    self.role_ids.include?(  User.role_id( "super_admin" ) )
  end
  
  def add_role( role_name )
    if User.role_id( role_name ) && role_name != "service_provider"
      self.role_ids << User.role_id( role_name )
      self.role_ids = self.role_ids.uniq.compact
      self.save
    end
  end
  
  def remove_role(role_name)
    self.role_ids = ( self.role_ids - [ User.role_id( role_name ) ]).flatten.compact
    self.save
  end

end