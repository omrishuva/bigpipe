class SessionsController < ApplicationController
  
  def create
    user = User.authenticate(params[:email], params[:password])
  	if user
    	session[:user_id] = user.id
      flash[:success] = "Logged in!"
    	redirect_to root_url
  	else
    	flash[:error] = "Invalid email or password"
    	redirect_to root_url
  	end
	end

  def destroy
    session[:user_id] = nil
    flash[:info] = "Logged out!"
    redirect_to root_url
  end
end