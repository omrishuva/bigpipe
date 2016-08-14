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
    $permissions["views"]["user_navtabs"]["permissions"].each do |navtab, permissions|
      if permissions["permitted_accounts"].present?
        allowed_navtabs << navtab if account_permitted?( permissions ) && role_permitted?( permissions )
      else
          allowed_navtabs << navtab if role_permitted?( permissions )
      end
    end
    allowed_navtabs
  end
  
  def account_permitted?( permissions )
    permissions["permitted_accounts"].size > [permissions["permitted_accounts"] - [current_user.account_type] ].flatten.size
  end
  
  def role_permitted?( permissions )
    permissions["permitted_roles"].size > [permissions["permitted_roles"] - [current_user.role_name] ].flatten.size
  end

  def default_active
    key = User.role_name( current_user.role_id )
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
    locals[:user].id == current_user_id
  end
  
  def widget_replace_selector( widget_data )
    "##{widget_data[:objectId]}_#{widget_data[:key]}.#{widget_data[:elementName]}"
  end

  def widget_id(locals)
    "#{locals[:objectId]}_#{locals[:key]}"
  end
  
  def input_id( locals )
    "input_#{widget_id(locals)}"
  end
  
  def build_nested_widget_selector_key( object_id, element_name, key )
    "##{object_id}.widgetControl[data-element-name='#{element_name}'][data-key='#{key}']"
  end

end