require "spec_helper"
RSpec.describe SessionsController do
  
  before :all do
    User.destroy_all
    params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "email" }
    @user = User.new(params)
    @user.save
    sleep 1
  end

  after :all do
    User.destroy_all
  end

  describe "POST login" do
    
    it "should create a new session if user is authenticated" do
      xhr :post, :create, { email: "omrishuva1@gmail.com", password: "zzzaaaa123" }
      expect(session[:user_id]).to eq @user.id
    end
    
    it "should redirect to root url when provided credentials are invalid" do
      xhr :post, :create, { email: "omrishuva1@gmail.com", password: "zzzaaaa1" }
      expect( response.content_type).to eq Mime::JS
    end

  end
  
  describe "GET destroy" do
    
    it "should redirect to root url" do
      get :destroy
      expect(response).to redirect_to(root_url)
    end
     
    it "should assign session user id with null value" do
      xhr :post, :create, { email: "omrishuva1@gmail.com", password: "zzzaaaa123" }
      get :destroy
      expect(session[:user_id]).to be nil
    end

  end

end