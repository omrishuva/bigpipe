module RoleUtils
  
  def self.included(base)
    base.extend(RoleClassMethods)
  end	
	
  module RoleClassMethods

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

    def service_name( service_id )
      roles_data["services_mapping"][service_id]
    end
    
    def service_id( service_name )
      roles_data["services"][service_name]
    end

    def service_ids
      roles_data["services"].map{|k,v| v } 
    end
    
    def services
       roles_data["services"].map{|k,v| k } 
    end

  end

  def set_default_role
    self.role_ids = self.class::DEFAULT_ROLE
  end

  def has_role?
    self.role_ids.present?
  end
  
  def roles
    self.role_ids.map{ |role_id| User.role_name( role_id )  }
  end
  
  def services
    self.service_ids.map{ |service_id| User.service_name( service_id )  }    
  end

  def roles_and_services
    @roles_and_services ||= [self.roles, self.services].flatten
  end

  def admin?
    self.role_ids.include?(  User.role_id( "admin" ) )
  end
  
  def service_provider?
    self.role_ids.include?(  User.role_id( "service_provider" ) )
  end

  def add_role( role_name )
    if User.role_id( role_name )
      self.role_ids << User.role_id( role_name )
      self.role_ids.uniq!
      self.save
    end
  end

  def add_service( service_name )
    if User.service_id( service_name )
      unless self.service_ids.present?
        self.service_ids = [User.service_id( service_name )]
      else
        self.service_ids << User.service_id( service_name )
        self.service_ids.uniq!
      end
      self.role_ids << User.role_id( "service_provider" )
      self.role_ids.uniq!
      self.save
    end
  end


end