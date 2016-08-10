require "spec_helper"

RSpec.describe Account do
	
	before :all do
		params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "email", phone_verified: true }
		@user = User.new( params )
		@user.save
		Account.create_freelancer_account( @user )
	end

	after :all do
		User.destroy_all
		Account.destroy_all
	end

	describe "create freelacer account" do
		
		it "should create a new accout record with a freelancer account type" do
			expect( Account.last.account_type ).to eql "freelancer"
		end

		it "should assign an owner role to the user" do
			expect( @user.role_ids ).to eql [1,4]
		end

		it "should assign the user id to the owners field in the account" do
			expect( Account.last.owners ).to eql [@user.id]
		end
		
		it "should assign the account id to the current_account_id field in the user record" do
			expect(@user.current_account_id).to eql Account.last.id
		end
		
		it "should the account id to the user linked accounts list" do
			expect(@user.linked_account_ids).to eql [Account.last.id]
		end

		it "should create only one account record" do
			expect( Account.where( [{ k: "owners", v: @user.id, op: "=" }] ).size ).to eql 1
		end

	end
end