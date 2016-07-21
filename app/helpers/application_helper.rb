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
    allowed_navtabs = []
    $permissions["views"]["user_navtabs"]["permissions"].each do |key, values|
      allowed_navtabs << key if values.size > [values - current_user.roles_and_services ].flatten.size
    end
    allowed_navtabs
  end

  def default_active
    if current_user.service_provider?
      key = User.service_name( current_user.service_ids.max )
    else
      key = User.role_name( current_user.role_ids.max )
    end
    $permissions["views"]["user_navtabs"]["default_active"][key]
  end

  def widget_state( locals )
    if locals[:state] != "edit" && not( locals[:value].present? ) && locals[:isWidgetOwner]
      :owner_before_commit
    elsif locals[:state] != "edit" && locals[:value].present? && locals[:isWidgetOwner]
      :owner_after_commit
    elsif locals[:state] != "edit" && locals[:value].present? && !locals[:isWidgetOwner]
      :user_after_commit
    elsif locals[:state] == 'edit' && locals[:isWidgetOwner]
      :edit
    end
  end

  def is_widget_owner( locals )
    return false if locals[:isWidgetOwner] == false
    locals[:user].id == current_user.id
  end

end