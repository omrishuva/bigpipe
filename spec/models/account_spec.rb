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
		AccountRole.destroy_all
	end

	describe "create freelacer account" do
		
		it "should create a new accout record with a freelancer account type" do
			expect( Account.last.account_type ).to eql "freelancer"
		end

		it "should assign an owner role to the user" do
			expect( @user.is_account_owner? ).to eql true
		end

		it "should assign the user id to the owners field in the account" do
			expect( Account.last.owners.first.id ).to eql @user.id
		end
		
		it "should assign the account id to the current_account_id field in the user record" do
			expect(@user.current_account_id).to eql Account.last.id
		end
		
		it "should create a linked account record" do
			expect(@user.linked_accounts.first.id).to eql Account.last.id
		end
		it "should create an AccountUser record" do
			expect( AccountRole.last.user_id ).to eql @user.id
		end

	end
end