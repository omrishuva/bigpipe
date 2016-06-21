class UsersController < ApplicationController
   
  skip_before_action :verify_authenticity_token, only: [:fb_lead, :pipedrive]

  def new
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end

  def create
    @user = User.new(params[:user])
    session[:user_id] = @user.id if @user.save
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end
  
  def authenticate_phone
    if params[:user][:phone].present?
        current_user.save_phone( params[:user][:phone] )
        if current_user.errors[:phone]
          flash[:error] = "Number already exists in our system, please user a different number"
        end
    elsif params[:user][:phone_verification_code].present?
      current_user.verify_phone_number( params[:user][:phone_verification_code] )
    elsif !params[:user][:phone].present?
      flash[:error] =  "Please enter your phone number"
    end
    
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end
  
  def resend_phone_number
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end

  def password_recovery_email 
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  
  end
  
  def select_new_password
    begin
      if params[:user] && params[:user][:email].present?
        @email_sent = true
        @user = User.find_by( [ { k: "email",  v: params[:user][:email], op: "=" } ] )
        if @user
          password_recovery_code = rand.to_s[2..5]
          @user.update(password_recovery_code: password_recovery_code )
          SendPasswordRecoveryEmail.perform_later( email: @user.email, name: @user.name, password_recovery_code: password_recovery_code )
        else
          flash[:error] = "Your email was not found in the system" 
        end
      else
        @success = false
        flash[:error] = "We couldn't find your email adress" 
      end
    rescue => e
      logger.error "app_log #{e.message} ---- #{e.backtrace}"
    end
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end
  
  def set_new_password

    @user = User.find_by( [ { k: "email", v: params[:user][:email], op: "=" } ] )
    if params[:user][:authentication_code] == @user.password_recovery_code
      @user.set_password( params[:user][:password] )
      flash[:success] = "Password changed successfully"
      @success = true
    else
      flash[:error] = "The code you entered does not match the one we sent you"
    end

    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end
  
  def change_locale
    current_user.update(locale: params[:l]) if current_user
    session[:current_locale] = params[:l]
    redirect_to "/"
  end

  def crm
    @users = User.all
  end
  
  def fb_lead
    begin
      user_params = params[:Parameters].merge!( password: User.generate_password, phone_verfied: true )
      user =  User.new( user_params )
      user.save
      user.create_pipedrive_lead_deal
      render status: 200, json: params
    rescue => e
      p "p #{e.message}  -- #{e.backtrace}"
      Rails.logger.debug "debug #{e.message}  -- #{e.backtrace}"
      Rails.logger.info "info #{e.message}  -- #{e.backtrace}"
      render status: 500, json: user_params
    end
  end

  def pipedrive
    Rails.logger.info params[:Parameters]["meta"]
    user_id = params[:Parameters]["meta"]["id"]
    Rails.logger.info "Create User"
    Rails.logger.info  User.create_from_pipedrive( Pipedrive::Person.find( user_id ) )
    Rails.logger.info "======================================="
    render status: 200, json: params
  end

  def index
  end

end