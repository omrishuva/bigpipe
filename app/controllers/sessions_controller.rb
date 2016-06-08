class SessionsController < ApplicationController
  
  skip_before_action :verify_authenticity_token, only: [:create, :new]
  
  def new
    respond_to do |format|
      format.js { }
      format.json { }
    end
  end
  
  def create
    @user = User.authenticate(user_params)
  	if @user 
    	session[:user_id] = @user.id
      flash[:success] = "Logged in"
  	else
    	flash[:error] = "Invalid email or password"
  	end
    respond_to do |format|
      format.js { }
      format.json { render json: @user }
    end
	end

  def destroy
    session[:user_id] = nil
    flash[:info] = "Logged out"
    redirect_to root_url
  end

end

private

def user_params
  params.select{|k,v| [:name, :email, :password, :profile_picture, :auth_provider].include?(k.to_sym) }.symbolize_keys
end