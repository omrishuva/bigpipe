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
      expect( response).to redirect_to  "/activities/#{@user.activities.first.id}"
    end
    
    it "should set the state to draft" do
      controller.stub(:current_user).and_return(@user)
      get :new_activity, user_id: @user.id
      expect( @user.activities.last.state).to eql "draft"  
    end

  end

  describe "POST save_scheduling" do
    
    
    context "specific date configuration blob" do
      
      before :each do
        user_params = { name: "owner", email: "owner@.activity.market", password: "123456", auth_provider: "email"  }
        @user = User.new( user_params )
        @user.save
        @account = Account.create_freelancer_account( @user )
        @activity = Activity.new( account_id: @account.id, title: "Untitled Activity" )
        @activity.save
        @date = DateTime.now
        @params =  { schedulingType:"specificDate", activityId: @activity.id,  selectedDate: @date, activityLeader: @user.id } 
        SendAccountUserInvitationEmail.stub(:perform_later)
      end

      after :each do
        Activity.destroy_all
        Account.destroy_all
        User.destroy_all
      end
      
      it "should save the recuring event scheduling" do
        controller.stub(:current_user).and_return(@user)
        xhr :post, :save_scheduling, @params
        expect( @activity.reload!.scheduling_configuration ).to eql ["specificDate_#{@date}_#{@user.id}"]
      end

      it "should save multiple dates" do
        controller.stub(:current_user).and_return(@user)
        xhr :post, :save_scheduling, @params
        xhr :post, :save_scheduling, @params
        expect( @activity.reload!.scheduling_configuration.size ).to eql 2
      end
    end

    context "recuring event configuration blob" do
      
      before :each do
        user_params = { name: "owner", email: "owner@.activity.market", password: "123456", auth_provider: "email"  }
        @user = User.new( user_params )
        @user.save
        @account = Account.create_freelancer_account( @user )
        @activity = Activity.new( account_id: @account.id, title: "Untitled Activity" )
        @activity.save
        @date = DateTime.now
        @params =  { schedulingType:"recurringEvent", activityId: @activity.id, selectedDayOfWeek: "Sunday",selectedTime: "12:30 PM", activityLeader: @user.id } 
        SendAccountUserInvitationEmail.stub(:perform_later)
      end

      after :each do
        Activity.destroy_all
        Account.destroy_all
        User.destroy_all
      end
    
      it "should save the recuring event scheduling" do
        controller.stub(:current_user).and_return(@user)
        xhr :post, :save_scheduling, @params
        expect( @activity.reload!.scheduling_configuration ).to eql ["recurringEvent_#{@params[:selectedDayOfWeek]}@#{@params[:selectedTime]}_#{@user.id}"]
      end

      it "should save multiple dates" do
        controller.stub(:current_user).and_return(@user)
        xhr :post, :save_scheduling, @params
        xhr :post, :save_scheduling, @params
        expect( @activity.reload!.scheduling_configuration.size ).to eql 2
      end
    end

  end


end