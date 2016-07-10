module ApplicationHelper

	def supported_locales
		temp = SupportedLocales.all
		temp.delete( I18n.locale )
		temp
	end

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-danger", info: "alert-info" }[flash_type.to_sym]
  end
  
  def profile_pic_src
  	current_user.try(:profile_picture).present? ? current_user.profile_picture : 'genderless_silhouette.png'
  end

  def users_admin_page_title( service_provider_type, role )
    if service_provider_type
      service_provider_type.pluralize.humanize
    else
      role.pluralize.humanize
    end
  end

  def available_navtabs
    navtabs_list = $permissions["views"]["user_navtabs"]
    role_navtabs = current_user.role_ids.map{ |role_id| navtabs_list["roles"][User.role_name(role_id)] }
    service_navtabs = current_user.service_ids.map{ |service_id| navtabs_list["services"][User.service_name(service_id)] }
    [ role_navtabs, service_navtabs ].flatten.uniq.compact.sort
  end

end