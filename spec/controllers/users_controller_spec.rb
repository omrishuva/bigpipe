require "spec_helper"

RSpec.describe UsersController do
  
  before :each do
    User.destroy_all
    @play_params = { user: { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play"  } } 
  end

  after :all do
    User.destroy_all
  end

  describe "POST signup" do
		
		it "should create a new user if user params are valid" do
      user_count =  User.all.size
      xhr :post, :create, @play_params
      sleep 3
      expect(User.all.size).to eq (user_count + 1)
    end
    

    it "should create a new session if user params are valid" do
      xhr :post, :create, @play_params
      sleep 3
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
  
  describe "POST authenticate phone" do
    
    before :all do
      # User.destroy_all
      @valid_params = { name: "omri shuva", email: "omrishuva1@gmail.com", auth_provider: "facebook" }
      @user = User.new(@valid_params)
      @user.save
    end

    context "after fb auth" do
      
      context "first step - phone " do
    
        it "should save phone number in db" do
          controller.stub(:current_user).and_return(@user)
          Sms.any_instance.stub(:send_message).and_return(:return_value) 
          xhr :post, :authenticate_phone, { user: { phone: "972526733740" } }
          expect(@user.phone).to eql "972526733740"
        end
        
        it "should generate verification code when phone params is passed" do
          controller.stub(:current_user).and_return(@user)
          Sms.any_instance.stub(:send_message).and_return(:return_value)
          xhr :post, :authenticate_phone, { user: { phone: "972526733740" } }
          expect(@user.phone_verification_code).to_not be nil
        end
    
        # it "should send verification code in sms to user" do
        #   controller.stub(:current_user).and_return(@user)
        #   Sms.any_instance.stub(:send_message).and_return(:return_value)
          
        #   xhr :post, :authenticate_phone, { user: { phone: "972526733740" } }
        #   expect_any_instance_of(Sms).to receive(:send_message).and_return(true)
        # end
      
      end
    
    end

    context "second step - verification code" do

      it "should assign phone_verified attribute to true" do

      end

    end

  end 

  describe "GET change_locale" do
    
    before :all do
      User.destroy_all
      @play_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play", phone_verified: true, locale: "he"  } 
      @user = User.new(@play_params)
      @user.save
    end
    
    before :each do
      ApplicationController.any_instance.stub(:current_user).and_return(@user)
    end

    it "should change user locale if user is logged in" do
      get :change_locale, { locale: "en" }
      expect( @user.locale ).to eq "en"
    end

    it "should change session current_locale" do
      @user.update(locale: "he")
      get :change_locale, { locale: "en" }
      expect( session[:current_locale] ).to eq "en"
    end

    it "should change I18n.locale" do
      I18n.locale == "he"
      get :change_locale, { locale: "en" }
      expect( I18n.locale ).to eq :en
    end

  end

  describe "POST fb_lead" do
    
    before :all do
      @fb_lead_params = { name: "test user", email: "testuser@play.org.il", phone: "0526333333", fb_id: 111111, campaign: "Tennis", media_source: "facebook", created_at: Time.now.to_i  }
    end
    
    before :each do
      User.destroy_all
      User.any_instance.stub(:pipeline_id).and_return( { leads: 3 } ) #test pipeline
    end

    after :each do
      User.last.destroy
    end

    it "should create a user record in the database" do
      users_count = User.all.size
      post :fb_lead, @fb_lead_params
      expect(User.all.size).to eq ( users_count + 1 )
    end
    
    it "should generate a matching pipedrive person" do
      post :fb_lead, @fb_lead_params
      new_user = User.last
      expect(new_user.pipedrive_person.id).to eq new_user.pipedrive_id
    end

    it "should generate a matching pipedrive deal" do
      post :fb_lead, @fb_lead_params
      new_user = User.last
      expect(new_user.pipedrive_person.deals[0].weighted_value).to eq 270
    end

  end

  describe "GET users/:type" do

    before :all do
      @valid_params = { name: "omri shuva", email: "omrishuva1@gmail.com", auth_provider: "facebook" }
      @user = User.new(@valid_params)
      @user.save
    end
    
    after :all do
      @user.destroy
    end

    it "should redirect to root url when user is not an admin" do
      controller.stub(:current_user).and_return(@user)
      get :users, type: "trainer"
      expect( response).to redirect_to  "/"
    end

    it "should be allowed for admin users" do
      @user.update(role: 1)
      controller.stub(:current_user).and_return(@user)
      get :users, type: "trainer"
      expect( response.status).to be 200
    end

  end


end