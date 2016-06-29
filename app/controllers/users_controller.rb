class UsersController < ApplicationController
   
  skip_before_action :verify_authenticity_token, only: [:fb_lead]

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
    @users = User.where( [ { k: "role",  v: $user_roles[params[:type]], op: "=" } ] )#.sort_by{|user| user.created_at }.reverse
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
  
  def add_trainer
    if params[:user].present?
      @user = User.new_trainer( params )
      redirect_to "/trainer/new" 
    end
  end

  def home_page
  end

end