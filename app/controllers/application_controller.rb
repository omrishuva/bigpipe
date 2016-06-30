class ApplicationController < ActionController::Base
  
  protect_from_forgery with: :exception

  before_filter :set_locale
  before_filter :authorize
  before_filter :clear_flash_messages

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user

  def authorize
    
    redirect_to root_url unless allowed?
  end
  
  def recognize_path
  	path_params = Rails.application.routes.recognize_path( request.env['PATH_INFO'] )
  	"#{path_params[:controller]}/#{path_params[:action]}"
  end
  
  def current_language_direction
    I18n.locale == :he ? :rtl : :ltr
  end
  
  helper_method :current_language_direction

  private 
  
  def set_locale
    I18n.locale = current_user.try(:locale) || session[:current_locale]
  end

  def clear_flash_messages
    flash.clear
  end
  
  def allowed?
    return true unless controller_permissions
     action_permissions
    if action_permissions.nil?
      true
    else
      action_permissions.include?( current_user.try(:role_name)  )
    end
  end
  
  def controller_permissions
    $permissions[params['controller']]
  end
  
  def action_permissions
    controller_permissions[params['action']]
  end

end
