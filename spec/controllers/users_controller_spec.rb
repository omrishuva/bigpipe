require "spec_helper"

RSpec.describe UsersController do
  
  before :each do
    User.destroy_all
    @play_params = { user: { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play"  } } 
  end
  
  describe "POST signup" do
		
		it "should create a new user if user params are valid" do
      user_count =  User.all.size
      xhr :post, :create, @play_params
      expect(User.all.size).to eq (user_count + 1)
    end
    

    it "should create a new session if user params are valid" do
      xhr :post, :create, @play_params
      expect(session[:user_id]).to_not be nil
    end
    
    it "should render js" do
      xhr :post, :create, { user:{  name: "", email: "", password: "" } }
      expect( response.content_type).to eq Mime::JS
    end

  end
  
  describe "GET signup" do  
    it "should render js" do
      xhr :get, :new
     	expect( response.content_type).to eq Mime::JS
    end
  end

end