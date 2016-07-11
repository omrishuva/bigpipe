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

  def set_default_role_and_service
    self.role_ids = self.class.default_role unless self.role_ids.present?
    self.service_ids = self.class.default_service unless self.service_ids.present?
  end

  def has_role_and_service?
    self.service_ids.present? && self.role_ids.present?
  end
  
  def roles
    self.role_ids.map{ |role_id| User.role_name( role_id )  }.compact
  end
  
  def services
    self.service_ids.map{ |service_id| User.service_name( service_id )  }.compact
  end

  def roles_and_services
    [self.roles, self.services].flatten
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
      self.role_ids = self.role_ids.uniq.compact
      self.save
    end
  end

  def add_service( service_name )
    set_default_role_and_service
    self.service_ids << User.service_id( service_name )
    self.service_ids.uniq!
    self.role_ids << User.role_id( "service_provider" )
    self.role_ids = self.role_ids.uniq.compact
    save
  end


end