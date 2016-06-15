require "spec_helper"

RSpec.describe ActiveJob::QueueAdapters::PubSubQueueAdapter do
	
	before :each do
		PubsubUtils.delete_all_topics
		PubsubUtils.delete_all_subscriptions
	end

	describe :enqueue do
		
		before :each do
			SendPasswordRecoveryEmail.perform_later( email: "omrishuva1@gmail.com", name: "omri shuva", password_recovery_code: "1234" )
		end

		it "should create new topic" do
			expect( PubsubUtils.get_all_topic_names[0] ).to eq "test-SendPasswordRecoveryEmail"
		end

		it "should create a new now subscription " do
			expect( PubsubUtils.get_all_subscription_names[0] ).to eq "test-now"
		end
		
		it "should enqueue SendPasswordRecoveryEmail job" do
			sub = $pubsub.find_subscription( "#{Rails.env}-now" )
			expect( sub.pull[0].attributes["email"] ).to eq "omrishuva1@gmail.com"
		end

	end

end