require "spec_helper"

RSpec.describe AccountsController do
  
  before :all do
    User.destroy_all
    params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "email"  } 
    @user = User.new( params )
    @user.save
    Account.create_freelancer_account( @user )
  end

  after :all do
    User.destroy_all
    Activity.destroy_all
    Account.destroy_all
  end

  describe "POST upgrade_to_business_account" do

    it "should change the account type to business" do
      controller.stub(:current_user).and_return(@user)
  	  xhr :post, :upgrade_to_business_account, { account_id: @user.current_account.id }
      expect( @user.account_type ).to eql "business"
    end

  end




end