class UsersController < ApplicationController

  def new
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      #@user.send_and_save_phone_verification_code
      session[:user_id] = @user.id
      flash[:success] = "Logged in!"
    end
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
  end
  
  def authenticate_phone
    if params[:user][:phone]
      current_user.save_phone( params[:user][:phone] )
    elsif params[:user][:phone_verification_code]
      current_user.verify_phone_number( params[:user][:phone_verification_code] )
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
      @user = User.find_by( :email, params[:user][:email] )
      if @user
        AppMailer.password_recovery_code_mail(@user).deliver_now
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
    @user = User.find_by( :email, params[:user][:email] )
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

  def index
    @users = User.all
  end

end