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
			sleep 2
			@duplicate_email_address_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526111111", password: "zzzaaaa123", auth_provider: "play" }
			user = User.new( @duplicate_email_address_params )
			user.save
			expect( user.errors ).to eq  email: ["already_exists"]
		end
		
		it "should validate email format" do
			@invalid_email_format_params = { name: "omri shuva", email: "omrishuva1gmail.com", phone: "0526111111", password: "zzzaaaa123", auth_provider: "play" }
			user = User.new(@invalid_email_format_params)
			user.save
			expect(user.errors).to eq  email: ["wrong_format"]
		end

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
			@play_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play" }
			User.destroy_all
			@fb_params = { auth_provider: "facebook", name: "omri shuva", email: "omrishuva1@gmail.com" }				
		end
		
		it "should encrypt password correctrly" do
			user = User.new(@play_params)
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

			it "should authenticate users that signed in originally with play" do
				user = User.new(@play_params)
				user.save
				sleep 1
				expect(User.authenticate(@fb_params).id).to eq user.id
			end

		end
	
		context "auth provider is play" do
			
			it "should authenticate user" do
				user = User.new(@play_params)
				user.save
				@play_params.merge!(password: "zzzaaaa123")
				expect(User.authenticate(@play_params)).to_not be nil
			end

			it "should not authenticate user if password is not correct" do
				user = User.new(@play_params)
				user.save
				expect(User.authenticate(@play_params)).to be nil
			end

			it "should not authenticate user if not exists" do
				expect(User.authenticate(@play_params)).to be nil
			end

		end

		context "roles & permissions" do
			
			before :each do
				User.destroy_all
				@play_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123", auth_provider: "play" }
				@fb_params = { auth_provider: "facebook", name: "omri shuva", email: "omrishuva1@gmail.com" }				
			end

			it "should set the user a user default role" do
				user = User.new(@play_params)
				user.save
				expect(user.role).to eq User::DEFAULT_ROLE
			end
			
			it "should not set the role if user already has a role" do
				user = User.new( @play_params.merge(role: 2) )
				user.save
				expect(user.role).to eq 2
			end
		
			it "should map role id to name" do 
				user = User.new( @play_params )
				user.save
				expect(user.role_name).to eq "consumer"
			end
		
		end

	end

	context "Trainer" do
			
		describe "add new trainer" do
			
			before :all do
				tempfile = File.new "cert.pdf","w"
				certificate = OpenStruct.new( tempfile: tempfile )
				@trainer_params = { user: { name: "omri shuva", email:"omri@play.org.il" ,phone:"0526733740" ,  gender:"male"}, certificate: certificate  }
				@user = User.new_trainer( @trainer_params )
				@file = $storage.find_bucket("test_certificates").file("certificate_#{@user.id}")
				@sub = $pubsub.find_subscription( "test-now" )
			end
			
			after :all do
				`rm cert.pdf`
				@file.delete
				@user.destroy
				@sub.pull.each{ |msg| msg.ack! }
			end

			it "should create the user with trainer role" do
				expect( @user.role_name ).to eq "service_provider"
			end
			
			it "should should save the certificate file in the storage" do
				file = $storage.find_bucket("test_certificates").file("certificate_#{@user.id}")
				expect(file).to_not be nil
			end
			
			it "should save the certificate path in the database" do
				expect(@file.public_url).to eq @user.trainer_certificate_url
			end

			it "should enqueue an invitation email task" do
				expect(@sub.pull.first.attributes["class"]).to eq "SendTrainerInvitationEmail"	
			end
			
		end
	end

end