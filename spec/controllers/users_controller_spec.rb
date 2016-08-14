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
      expect(new_user.pipedrive_person.deals[0].value).to eq 270
    end

  end
  
  describe "invite account user" do

    context "new" do
      
      before :all do
        @account_editor_params = { name: "editor", email: "editor@.activity.market", password: "123456", auth_provider: "email", role: "seller_account_editor"  }
      end

      before :each do
        account_owner_params = { name: "owner", email: "owner@.activity.market", password: "123456", auth_provider: "email"  }
        @account_owner = User.new( account_owner_params )
        @account_owner.save
        @account = Account.create_freelancer_account( @account_owner )
        SendAccountUserInvitationEmail.stub(:perform_later).and_return( true )
      end
    
      after :each do
        User.destroy_all
        Account.destroy_all
      end

      it "should create a new user" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( User.last.email).to eql @account_editor_params[:email]
      end

      it "should assign the account id as current_account" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( User.last.current_account.id ).to eql @account.id
      end

      it "should add the account id to the user linked accounts" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( User.last.linked_accounts.first.id ).to eql @account.id
      end
      
      it "should assign the chosen role to the new account user" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( User.last.role_id ).to eql 3
      end
      
       it "should add the user id to the accout editors list" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( @account.reload!.editors.map(&:id).include?(User.last.id) ).to be true
      end

       it "should generate an onboarding code for the user" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( User.last.onboarding_code ).to_not be nil
      end

      it "should set the user account status to pending" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( User.last.current_account_role.status ).to eql "pending"
      end

    end
    
    context " exists and doesn't have other linked accounts" do
      
      before :all do
        @account_editor_params = { name: "user", email: "user@.activity.market", role: "seller_account_editor"  }
      end

      before :each do
        account_owner_params = { name: "owner", email: "owner@.activity.market", password: "123456", auth_provider: "email"  }
        @account_owner = User.new( account_owner_params )
        @account_owner.save
        @account = Account.create_freelancer_account( @account_owner )
        user_params = { name: "user", email: "user@.activity.market", password: "123456", auth_provider: "email"  }
        @user = User.new( user_params )
        @user.save
        SendAccountUserInvitationEmail.stub(:perform_later).and_return( true )
      end
    
      after :each do
        User.destroy_all
        Account.destroy_all
      end

      it "should assign the account id as current_account" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( @user.reload!.current_account_id).to eql @account.id
      end

      it "should add the account id to the user linked accounts" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( @user.reload!.linked_accounts.map(&:id) ).to eql [@account.id]
      end

      it "should assign the chosen role to the new account user" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( @user.reload!.role_id ).to eql 3
      end
      
      it "should add the user id to the accout editors list" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( @account.reload!.editors.map(&:id).include?(@user.id) ).to be true
      end
      
      it "should generate an onboarding code for the user" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( @user.reload!.onboarding_code ).to_not be nil
      end

      it "should set the user account status to pending" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_editor_params
        expect( @user.reload!.current_account_role.status ).to eql "pending"
      end

    end

    context "exists and has other linked accounts" do
      
       before :all do
        @account_user_params = { name: "user", email: "user@.activity.market", role: "seller_account_user"  }
      end

      before :each do
        account_owner_params = { name: "owner", email: "owner@.activity.market", password: "123456", auth_provider: "email"  }
        @account_owner = User.new( account_owner_params )
        @account_owner.save
        @account = Account.create_freelancer_account( @account_owner )
        user_params = { name: "user", email: "user@.activity.market", password: "123456", auth_provider: "email"  }
        @user = User.new( user_params )
        @user.save
        @first_account = Account.create_freelancer_account( @user )
        SendAccountUserInvitationEmail.stub(:perform_later).and_return( true )
      end
    
      after :each do
        User.destroy_all
        Account.destroy_all
      end

      it "should add the account id to the user linked accounts" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_user_params
        expect( @user.reload!.linked_accounts.map(&:id).sort ).to eql [ @first_account.id, @account.id].sort
      end
      
      it "should assign the chosen role to the new account user" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_user_params
        expect( @user.reload!.role_id ).to eql 4
      end
      
      #should be moved to user spec
      it "should change the user current_account when switching accounts" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_user_params
        @user.switch_current_account( @account.id )
        expect( @user.reload!.current_account_id ).to eql @account.id
      end

      it "should change the user roles when switching accounts" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_user_params
        @user.switch_current_account( @account.id )
        expect( @user.reload!.role_id ).to eql 2
      end

       it "should generate an onboarding code for the user" do
        controller.stub(:current_user).and_return(@account_owner)
        post :add_account_user, user: @account_user_params
        expect( @user.reload!.onboarding_code ).to_not be nil
      end

    end
    
    describe "account user onboarding" do
      
      context "new" do
        
      end

      context "already exists in the system" do
        
      end

    end

  end
end