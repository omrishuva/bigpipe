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
  
  def get_widget_type_from_name( locals )
    multiple_state = $widget_names[:multiple_state]
    wizards = $widget_names[:wizard]
    return :multiple_state if multiple_state.include?( widget_name( locals ) )
    return :wizard if wizards.include?( widget_name( locals ) )
  end
  
  def widget_name( locals )
    locals[:wizardName] || locals[:widgetName]
  end

  def is_widget_owner( locals )
    return false if locals[:isWidgetOwner] == false
    locals[:user].id == current_user_id
  end
  
  def generate_button_id
    (0..32).to_a.map{|a| rand(16).to_s(16)}.join
  end
  
  def widget_replace_selector( widget_data )
    widget_data = widget_data[:wizardConf] if widget_data[:wizardConf].present?
    "##{widget_data[:objectId]}_#{widget_data[:key]}.#{widget_data[:elementName]}"
  end
  
  def widget_id(locals)
    locals = locals[:wizardConf] if locals[:wizardConf].present?
    "#{locals[:objectId]}_#{locals[:key]}"
  end
  
  def input_id( locals )
    "input_#{widget_id(locals)}"
  end
  
  def team_table_data
    data = []  
    current_user.current_account.members.each do |member|
      account_role = member.get_account_role( current_user.current_account.id )
      data << [member.name, member.email, User.role_ui_name( account_role.role_id.to_i ).singularize, account_role.status]
    end
    data
  end

  def prepare_placeholder( placeholder, objectName, key, value )
    if placeholder == "placeholderPattern"
      placeholder_patterns(value)["#{objectName}_#{key}"]
    else
      placeholder
    end
  end

  def placeholder_patterns( value )
    {
      "activities_max_guest_limit" => "#{I18n.t :set_guest_limit}: #{value || I18n.t(:unlimited) } ",
      "activities_duration" => "#{I18n.t :activity_duration}: #{value || '-' } #{I18n.t :hours} ",
      "activities_price" => "#{I18n.t :price}: #{ activity_price(value) || 'free' } ",
    }
  end

  def activity_price(value)
    value.to_i == 0 ? nil : value
  end

  def prepare_wizard_data( wizard_type )
    $wizards[wizard_type]
  end

end