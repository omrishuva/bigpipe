require "spec_helper"
RSpec.describe SessionsController do
  
  before :all do
    User.destroy_all
    params = { first_name: "omri", last_name: "shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123" }
    @user = User.new(params)
    @user.save
  end
  
  describe "GET login" do

    it "should render login template" do
      get :new
      expect(response).to render_template("sessions/new")
    end  
  
  end
  
  describe "POST login" do
    
    it "should create a new session if user is authenticated" do
      post :create, { email: "omrishuva1@gmail.com", password: "zzzaaaa123" }
      expect(session[:user_id]).to eq @user.id
    end
    
    it "should render login screen with an error message if credentials are invalid" do
      post :create, { email: "omrishuva1@gmail.com", password: "zzzaaaa1" }
      expect(response).to render_template("sessions/new")
    end

  end

end