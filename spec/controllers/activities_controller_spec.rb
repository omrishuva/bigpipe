require "spec_helper"

RSpec.describe ActivitiesController do
  

  after :all do
    User.destroy_all
    Activity.destroy_all
    Account.destroy_all
  end

  describe "GET new_activity" do

    before :each do
      User.destroy_all
      params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "email"  } 
      @user = User.new( params )
      @user.save
      sleep 1
    end

    after :each do
      Activity.destroy_all
      Account.destroy_all
    end

    it "should create a freelancer account for consumers" do
      controller.stub(:current_user).and_return(@user)
  	  get :new_activity, user_id: @user.id
      expect( @user.current_account ).to_not be nil
    end

    it "should create new activity and assign it to the users current active account" do
      controller.stub(:current_user).and_return(@user)
      get :new_activity, user_id: @user.id
      expect( @user.activities.first.account_id ).to eql @user.current_account.id
    end

    it "should not create a new freelancer accout if user is already has an account" do
      controller.stub(:current_user).and_return(@user)
      get :new_activity, user_id: @user.id
      first_create_account_id =  @user.current_account.id
      get :new_activity, user_id: @user.id
      second_create_account_id =  @user.current_account.id
      expect(first_create_account_id).to eql second_create_account_id
    end

    it "should redirect to the new activity page" do
      controller.stub(:current_user).and_return(@user)
      get :new_activity, user_id: @user.id
      sleep 1
      expect( response).to redirect_to  "/activities/#{@user.activities.first.id}"
    end

  end

  describe "get activity" do
  	
  end


end