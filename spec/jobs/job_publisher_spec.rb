require "spec_helper"
RSpec.describe JobPublisher do

	before :each do
  	PubsubUtils.delete_all_topics
  	PubsubUtils.delete_all_subscriptions
    $job_listeners = PubsubUtils.get_all_subscriptions
  end
   
  after :all do
    PubsubUtils.delete_all_topics
    PubsubUtils.delete_all_subscriptions
  end
  
  it "should create a new topic id doesn't exists" do
  	job_publisher =  JobPublisher.new( "Spec", "test_job", test: 123 )
  	expect( job_publisher.topic.name ).to eq "projects/play-prod/topics/test-Spec-test_job"
  end

  it "should create a new subscriber if doesn't exists" do
  	job_publisher =  JobPublisher.new( "Spec", "test_job", test: 123 )
  	expect(job_publisher.sub.sub.name).to eq "projects/play-prod/subscriptions/Sub-test-Spec-test_job"
  end

  it "should publish a message" do
  	job_publisher =  JobPublisher.new( "Spec", "test_job", test: 123 )
    binding.pry
  	message = job_publisher.sub.sub.pull[0].message.data 
  	result = message.include?("test-Spec-test_job")
  	expect(result).to be true
  end

end