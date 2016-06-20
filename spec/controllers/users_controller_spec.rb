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
      get :change_locale, { l: "en" }
      expect( @user.locale ).to eq "en"
    end

    it "should change session current_locale" do
      @user.update(locale: "he")
      get :change_locale, { l: "en" }
      expect( session[:current_locale] ).to eq "en"
    end

    it "should change I18n.locale" do
      I18n.locale == "he"
      get :change_locale, { l: "en" }
      expect( I18n.locale ).to eq :en
    end

  end

  describe "POST pipedrive" do
    
    before :all do
      @pipedrive_params = { Parameters: {"v"=>1, "matches_filters"=>nil, "meta"=>{"v"=>1, "action"=>"added", "object"=>"pushNotification", "id"=>115, "company_id"=>1040979, "user_id"=>1490483, "host"=>"play5.pipedrive.com", "timestamp"=>1466427546, "permitted_user_ids"=>["*"], "trans_pending"=>false, "is_bulk_update"=>false}, "retry"=>2, "current"=>{"id"=>3, "user_id"=>1490483, "company_id"=>1040979, "subscription_url"=>"https://play-prod.appspot.com/pipedrive", "type"=>"regular", "event"=>"added.pushNotification", "http_auth_user"=>"", "http_auth_password"=>"[FILTERED]", "add_time"=>"2016-06-20 12:59:06", "active_flag"=>true, "remove_time"=>nil, "http_last_response_code"=>nil}, "previous"=>nil, "event"=>"added.pushNotification", "user"=>{"v"=>1, "matches_filters"=>nil, "meta"=>{"v"=>1, "action"=>"added", "object"=>"pushNotification", "id"=>3, "company_id"=>1040979, "user_id"=>1490483, "host"=>"play5.pipedrive.com", "timestamp"=>1466427546, "permitted_user_ids"=>["*"], "trans_pending"=>false, "is_bulk_update"=>false}, "retry"=>2, "current"=>{"id"=>3, "user_id"=>1490483, "company_id"=>1040979, "subscription_url"=>"https://play-prod.appspot.com/pipedrive", "type"=>"regular", "event"=>"added.pushNotification", "http_auth_user"=>"", "http_auth_password"=>"[FILTERED]", "add_time"=>"2016-06-20 12:59:06", "active_flag"=>true, "remove_time"=>nil, "http_last_response_code"=>nil}, "previous"=>nil, "event"=>"added.pushNotification"}} }
    end
    
    before :each do
      User.destroy_all
    end

    it "should create a user record in the database" do
      users_count = User.all.size
      post :pipedrive, @pipedrive_params
      expect(User.all.size).to eq ( users_count + 1 )
    end

    it "should return 200" do
      post :pipedrive,@pipedrive_params
      binding.pry
    end


  end


end