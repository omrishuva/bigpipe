module RoleUtils
  
  def self.included(base)
    base.extend(RoleClassMethods)
  end	
	
  module RoleClassMethods
    
    # def default_role
    #   [ User.role_id( "consumer" ) ]
    # end

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

  def role_name
    User.role_name( self.cuurent_account.role_id )
  end
  
  def make_super_admin
    self.update( super_admin: true )
  end
  
  def remove_as_super_admin
    self.update( super_admin: false )
  end

  def super_admin?
    self.super_admin == true
  end
  
end