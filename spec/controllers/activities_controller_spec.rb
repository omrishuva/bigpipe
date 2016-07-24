require "spec_helper"

RSpec.describe ActivitiesController do
  
  before :each do
    User.destroy_all
    @play_params = { user: { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play"  } } 
  end

  after :all do
    User.destroy_all
  end

  describe "get new_activity" do
  	it "should be created only by owners and admin" do
  	end
  end

  describe "get activity" do
  	
  end


end