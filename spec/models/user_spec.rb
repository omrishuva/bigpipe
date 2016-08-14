require "spec_helper"

RSpec.describe User do
	
	before :each do
		@valid_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play", phone_verified: true }
		User.destroy_all
	end
	
	after :all do
		User.destroy_all
	end

	context "Validations" do
	
		it "should create a user entity if all params are correct" do
			expect(User.create(@valid_params)).to be true
		end
		
		it "should validate uniqueness of email" do
			User.create( @valid_params )
			sleep 3
			@duplicate_email_address_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526111111", password: "zzzaaaa123", auth_provider: "play" }
			user = User.new( @duplicate_email_address_params )
			user.save
			expect( user.errors ).to eq  email: ["already_exists"]
		end
		
		# it "should validate email format" do
		# 	@invalid_email_format_params = { name: "omri shuva", email: "omrishuva1gmail.com", phone: "0526111111", password: "zzzaaaa123", auth_provider: "play" }
		# 	user = User.new(@invalid_email_format_params)
		# 	user.save
		# 	expect(user.errors).to eq  email: ["wrong_format"]
		# end

		it "should validate uniqueness of phone" do
			User.create(@valid_params)
			@another_user_params = { name: "omri shuva", email: "omrishuva123@gmail.com", password: "zzzaaaa123", auth_provider: "play" }
			user = User.new(@another_user_params)
			user.save
			user.save_phone( "0526733740" )
			expect(user.errors).to eq  phone: ["already_exists"]
		end

		it "should not send sms if phone is not unique" do
			User.create(@valid_params)
			@another_user_params = { name: "omri shuva", email: "omrishuva123@gmail.com", password: "zzzaaaa123", auth_provider: "play" }
			user = User.new(@another_user_params)
			user.save
			user.save_phone( "0526733740" )
			user.should_not_receive(:send_and_save_phone_verification_code)
		end

		it "should validate presence of name" do
			@missing_name_params = {  email: "c21vqev@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play" }
			user = User.new(@missing_name_params)
			user.save
			expect(user.errors).to eq  name: ["is_missing"]
		end
		
		it "should validate presence of password" do
			@missing_password_params = { name: "omri shuva", email: "c21vqev@gmail.com", phone: "0526744632", password: "", auth_provider: "play" }
			user = User.new(@missing_password_params)
			user.save
			expect(user.errors).to eq  password: ["is_missing"]
		end

	end
	
	context "Authentication" do

		before :each do
			@email_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "email" }
			User.destroy_all
			@fb_params = { auth_provider: "facebook", name: "omri shuva", email: "omrishuva1@gmail.com" }				
		end
		
		it "should encrypt password correctrly" do
			user = User.new(@email_params)
			user.save
			expect(user.password_hash).to eq BCrypt::Engine.hash_secret("zzzaaaa123", user.password_salt)
		end
		
		context "auth provider is facebook" do

			it "should create a new user if new and from facebook" do
				user_count = User.all.count
				User.authenticate(@fb_params)
				sleep 1
				expect(User.all.count).to eq (user_count + 1)
			end
			
			it "should authenticate existing users" do
				user = User.new(@fb_params)
				user.save
				User.authenticate(@fb_params)
				expect(User.authenticate(@fb_params)).to_not be nil
			end

			it "should authenticate users that signed in originally with email" do
				user = User.new(@email_params)
				user.save
				sleep 1
				expect(User.authenticate(@fb_params).id).to eq user.id
			end

		end
	
		context "auth provider is email" do
			
			it "should authenticate user" do
				user = User.new(@email_params)
				user.save
				@email_params.merge!(password: "zzzaaaa123")
				expect(User.authenticate(@email_params)).to_not be nil
			end

			it "should not authenticate user if password is not correct" do
				user = User.new(@email_params)
				user.save
				expect(User.authenticate(@email_params)).to be nil
			end

			it "should not authenticate user if not exists" do
				expect(User.authenticate(@email_params)).to be nil
			end

		end
	end

	context "roles & permissions" do
		
		# context "administraion" do
			
		# 	before :all do
		# 		User.destroy_all
		# 		consumer_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play" }
		# 		@consumer = User.new( consumer_params )
		# 		@consumer.save
		# 	end
			
		# 	it "should add role" do
		# 		@consumer.add_role( "admin" )
		# 		expect( @consumer.admin? ).to be true
		# 	end

		# 	it "should remove role" do 
		# 		@consumer.remove_role("admin")
		# 		expect( @consumer.admin? ).to be false
		# 	end

		# end

		# context "Consumer" do
			
		# 	before :all do
		# 		User.destroy_all
		# 		consumer_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play" }
		# 		@consumer = User.new( consumer_params )
		# 		@consumer.save
		# 	end

		# 	it "should set the user a default role" do
		# 		expect(@consumer.role_ids).to eq [1]
		# 	end
			
		# 	it "should map role id to name" do
		# 		expect(@consumer.roles).to eq ["consumer"]
		# 	end
		
		# end

		# context "Seller Account Owner" do

		# 	before :all do
		# 		User.destroy_all
		# 		account_owner_params = { name: "shimi shimon", email: "shimi@gmail.com", phone: "05263333333", password: "f2ev123v1v1", auth_provider: "email"}
		# 		@account_owner = User.new_account_owner( account_owner_params )
		# 		@account_owner.save
		# 	end
			
		# 	it "should multiple consumer and account owner roles" do
		# 		expect(@account_owner.role_ids.sort).to eq [1,4]
		# 	end
	
		# end
		
		# context "Seller Account Admin" do

		# 	before :all do
		# 		User.destroy_all
		# 		account_admin_params = { name: "shimi shimon", email: "shimi@gmail.com", phone: "05263333333", password: "f2ev123v1v1", auth_provider: "email"}
		# 		@account_admin = User.new_account_owner( account_owner_params )
		# 		@account_admin.save
		# 	end
			
		# 	it "should multiple consumer and account owner roles" do
		# 		expect(@account_admin.role_ids.sort).to eq [1,3]
		# 	end
		# end

		# context "Seller Account User" do

		# 		before :all do
		# 		User.destroy_all
		# 		account_user_params = { name: "shimi shimon", email: "shimi@gmail.com", phone: "05263333333", password: "f2ev123v1v1", auth_provider: "email"}
		# 		@account_user = User.new_account_owner( account_owner_params )
		# 		@account_user.save
		# 	end
			
		# 	it "should multiple consumer and account owner roles" do
		# 		expect(@account_user.role_ids.sort).to eq [1,2]
		# 	end
		# end

	end
end