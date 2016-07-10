module RoleUtils
	
	def set_default_role
    self.role = self.class::DEFAULT_ROLE
  end
  
  def set_locale
    self.locale = I18n.locale.to_s
  end
  
  def has_locale?
    self.locale.present?
  end

  def has_role?
    self.role.present?
  end
  
  def role_name
    $user_roles["roles_mapping"][self.role]
  end
  
  def service_provider_name
    $user_roles["service_provider_types_mapping"][self.service_provider_type]
  end

  def admin?
    self.role == $user_roles["roles"]["admin"]
  end
  
end