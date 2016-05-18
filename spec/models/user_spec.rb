require "spec_helper"
RSpec.describe User do
	
	before :each do
		@valid_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526733740", password: "zzzaaaa123" }
		User.destroy_all
	end
	
	context "Validations" do
	
		it "should create a user entity if all params are correct" do
			expect(User.create(@valid_params)).to be true
		end
		
		it "should validate uniqueness of email" do
			User.create(@valid_params)
			@duplicate_email_address_params = { name: "omri shuva", email: "omrishuva1@gmail.com", phone: "0526111111", password: "zzzaaaa123" }
			user = User.new(@duplicate_email_address_params)
			user.save
			expect(user.errors).to eq  email: ["adress already exists"]
		end
		
		it "should validate email format" do
			@invalid_email_format_params = { name: "omri shuva", email: "omrishuva1gmail.com", phone: "0526111111", password: "zzzaaaa123" }
			user = User.new(@invalid_email_format_params)
			user.save
			expect(user.errors).to eq  email: ["is not valid"]
		end

		it "should validate uniqueness of phone" do
			User.create(@valid_params)
			@duplicate_email_address_params = { name: "omri shuva", email: "omrishuva123@gmail.com", phone: "0526733740", password: "zzzaaaa123" }
			user = User.new(@duplicate_email_address_params)
			user.save
			expect(user.errors).to eq  phone: ["number already exists"]
		end

		it "should validate length of phone" do
			@invalid_email_format_params = { name: "omri shuva", email: "c21vqev@gmail.com", phone: "05261111", password: "zzzaaaa123" }
			user = User.new(@invalid_email_format_params)
			user.save
			expect(user.errors).to eq  phone: ["number is not valid"]
		end

		it "should validate presence of name" do
			@missing_name_params = {  email: "c21vqev@gmail.com", phone: "0526733740", password: "zzzaaaa123" }
			user = User.new(@missing_name_params)
			user.save
			expect(user.errors).to eq  name: ["is missing"]
		end
		
		it "should validate presence of password" do
			@missing_password_params = { name: "omri shuva", email: "c21vqev@gmail.com", phone: "0526744632", password: "" }
			user = User.new(@missing_password_params)
			user.save
			expect(user.errors).to eq  password: ["is missing"]
		end

	end
	
	context "Authentication" do
		
		it "should encrypt password correctrly" do
			user = User.new(@valid_params)
			user.save
			expect(user.password_hash).to eq BCrypt::Engine.hash_secret("zzzaaaa123", user.password_salt)
		end

		it "should authenticate user" do
			user = User.new(@valid_params)
			user.save
			expect(User.authenticate("omrishuva1@gmail.com","zzzaaaa123")).to_not be nil
		end

		it "should not authenticate user if password is not correct" do
			user = User.new(@valid_params)
			user.save
			expect(User.authenticate("omrishuva1@gmail.com","zzzaaaa13")).to be nil
		end

	end

end