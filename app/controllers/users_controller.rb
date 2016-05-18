class UsersController < ApplicationController

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      session[:user_id] = @user.id
      flash[:success] = "Logged in!"
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