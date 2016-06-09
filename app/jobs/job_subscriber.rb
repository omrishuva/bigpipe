class JobSubscriber
	
	attr_accessor :topic, :sub_name, :sub

	def initialize( topic, job_key )
		@topic = topic
		@sub_name = "Sub-#{job_key}"
		PubsubUtils.delete_subscription( sub_name )
		@sub = topic.subscribe( sub_name )
		register_job_listener
	end
	
	private

	def register_job_listener
		$job_listeners << sub
	end

end