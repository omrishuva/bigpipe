class UsersController < ApplicationController
   
  skip_before_action :verify_authenticity_token, only: [:fb_lead, :service_provider_login]

  def new
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end

  def create
    @user = User.new( params[:user] )
    @embedded_form = params[:embedded]
    
    if @user.save
      session[:user_id] = @user.id 
      if params[:seller].to_s == "true"
        render js: "window.location = '/account/setup/#{@user.id}' "
      else
        respond_to do |format|
          format.js { }
          format.json { render json: @user }
        end
      end
    else
    
      respond_to do |format|
        format.js { }
        format.json { render json: @user }
      end
    
    end
  end
  
  def join_as_expert
    
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

    if User.set_new_password( params[:user][:email], :password_recovery_code, params[:user][:authentication_code],  params[:user][:new_password] )
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
    query_params = [ { k: "role_ids",  v: User.role_id( params[:role] ), op: "=" } ]
    query_params << { k: "service_ids", v: User.service_id( params[:spt] ), op: "=" } if params[:spt]
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
  
  def invite_account_user
  end
  
  def add_account_user
    if !params[:user][:email].present?
      flash[:error] = "Please fill in all the fields"
      render "invite_account_user"
    else 
      @user = current_user.new_account_user( params[:user] )
      if @user.errors.present?
        render "invite_account_user"
      else
        redirect_to "/account_user/new", :flash => { :success => "invitation sent to #{@user.name}" }
      end
    end
  end

  def onboarding_page
    redirect_to root_url and return unless params[:account_id]
    @user = User.find( params[:user_id] )
    session[:current_locale] = @user.locale
    render layout: 'onboarding_page'
  end

  def onboarding_form_submit
    if user = User.set_new_password( params[:email], :onboarding_code, params[:onboardingCode],  params[:password] )
      user.current_account_role.update( status: "active" )
      session[:user_id] = user.id
      redirect_to "/"
    else
      flash[:error] = "The code you entered does not match the one we sent you"
    end
  end

  def existing_user_onboarding
    user = User.find( params[:user_id] )
    user.current_account_role.update( statue: "active" )
    user.switch_current_account( params[:account_id] )
    redirect_to "/"
  end

  def profile
    @nav = params[:nav]
    @user = User.find( params[:user_id] )
  end
  
  def profile_navigation
    if current_user_id == params[:userId]
      @user = current_user
    else
      @user = User.find( params[:userId] )
    end
    respond_to do |format|
      format.js { }
    end
  end

  def service_provider_login
    @user = User.authenticate( params )
    if @user 
      session[:user_id] = @user.id
      flash[:success] = "Logged in"
      redirect_to '/me' and return
    end  
  end
  
  def home_page
    @activities = Activity.all
  end

end