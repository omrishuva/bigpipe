class UsersController < ApplicationController
   
  skip_before_action :verify_authenticity_token, only: [:fb_lead, :service_provider_login, :upload_image, :save_user_about_text]

  def new
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end

  def create
    @user = User.new( params[:user] )
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
    current_user.update(locale: params[:locale]) if current_user
    session[:current_locale] = params[:locale]
    redirect_to "/"
  end

  def users
    query_params = [ { k: "role",  v: $user_roles["roles"][params[:role]], op: "=" } ]
    query_params << { k: "service_provider_type", v: $user_roles["service_provider_types"][params[:service_provider]], op: "=" } if params[:service_provider]
    @users = User.where( query_params ).sort_by{|user| user.created_at }.reverse
    @today =  @users.select{|user| user.created_at.to_date.to_s == Date.today.to_s }.size
    @yesterday =  @users.select{|user| user.created_at.to_date.to_s == Date.yesterday.to_s }.size
  end 

  def fb_lead
    user_params = params.merge!( password: User.generate_password, phone_verified: true )
    user_params.delete(:controller)
    user_params.delete(:action)
    user =  User.new( user_params )
    user.save
    user.create_pipedrive_lead_deal unless user.errors.present?
    render status: 200, json: user_params
  end
  
  def add_service_provider
    @service_provider_type = params[:spt]

    @user = User.new_trainer( params ) if params[:user].present?
    if !@user
      render "add_service_provider"
    elsif @user && @user.errors.present?
      render "add_service_provider"
    else
      redirect_to '/users/service_provider'
    end
  end
  
  def service_provider_onboarding
    redirect_to root_url and return unless params[:spid]
    @user = User.find( params[:spid] )
    session[:current_locale] = @user.locale
  end

  def me
    @cover_image = current_user.cover_image_cloudinary_id || "http://placehold.it/700x400"
  end
  
  def public_profile
    @user = User.find( params[:id] )

  end

  def service_provider_login
    @user = User.authenticate( params )
    if @user 
      session[:user_id] = @user.id
      flash[:success] = "Logged in"
      redirect_to '/me' and return
    end  
  end

  def upload_image
    cloudinary_image = Cloudinary::Uploader.upload( params["image"].tempfile, eager:{ width: 700, height: 400, crop: :thumb, gravity: :face } )
    current_user.update( cover_image_cloudinary_id: cloudinary_image["public_id"] )
    @image_url =  "#{cloudinary_image['public_id']}.jpg"
    respond_to do |format|
      format.js { }
      format.json { render json: @image_url }
    end
  end
  
  def edit_user_about_text
    respond_to do |format|
      format.js { }
      format.json { render json: @image_url }
    end
  end
  
  def cancel_user_edit_about_text
    respond_to do |format|
      format.js { }
    end
  end
  
  def save_user_about_text
    current_user.update( about_text: params[:user_about_text] )
    respond_to do |format|
      format.js { }
    end
  end

  def home_page
  end

end