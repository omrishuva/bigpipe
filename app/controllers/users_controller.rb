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
      @user.send_and_save_phone_verification_code
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

  def index
    @users = User.all
  end

end