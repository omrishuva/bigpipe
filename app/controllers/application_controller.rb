class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception

  before_filter :set_locale
  before_filter :authorize
  before_filter :clear_flash_messages
  
  DEFAULT_LOCALE  = :en
  
  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def authorize
    redirect_to root_url and return if not allowed?
  end
  
  def recognize_path
  	path_params = Rails.application.routes.recognize_path( request.env['PATH_INFO'] )
  	"#{path_params[:controller]}/#{path_params[:action]}"
  end
  
  def current_direction
    @current_direction ||= I18n.locale == :he ? :rtl : :ltr
  end

  helper_method :current_direction

  private 
  
  def set_locale
    if current_user && current_user.admin? && controller_permissions.present? && action_permissions == "admin"
      I18n.locale = DEFAULT_LOCALE
    else
      I18n.locale = current_user.try(:locale) || session[:current_locale]
    end
  end

  def clear_flash_messages
    flash.clear
  end
  
  def allowed?
    return true unless controller_permissions
    return user_is_owner_or_admin if action_permissions == "owner_or_admin"
    if action_permissions.nil?
      true
    else
      User.role_id( action_permissions ).to_i <= current_user.role_ids.max
    end
  end
  
  def user_is_owner_or_admin
    params[:user_id].to_s == current_user.id.to_s || current_user.admin?
  end
  
  def controller_permissions
    $permissions["controllers"][params['controller']]
  end
  
  def action_permissions
    controller_permissions[params['action']]
  end

end
