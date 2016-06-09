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
    # redirect_to '/login' if !current_user
  end
  
  def recognize_path
  	path_params = Rails.application.routes.recognize_path( request.env['PATH_INFO'] )
  	"#{path_params[:controller]}/#{path_params[:action]}"
  end
 
  private 
  
  def clear_flash_messages
    flash.clear
  end

  def set_locale
    I18n.locale = params[:l] || I18n.default_locale
  end
  
end
