class JobPublisher
  	
  attr_accessor :topics, :publisher_name, :queue, :job_name, :job_id, :args, :topic, :sub

	def initialize( publisher_name, job_name, queue, args = { } )
		@job_name = job_name
		@publisher_name = publisher_name
		@queue =  "#{Rails.env}-#{queue}"
		@args = set_args(args)
		@topics = set_topics
		@topic = find_or_create_topic
		@job_id = generate_job_id
		publish!
	end
		
	private
		
	def publish!
		PubSubQueueAdapter.enqueue( topic, job_id, args )
		#Rails.logger.info "publish #{topic.publish( job_id, args  )}"
	end

	def generate_job_id
		"#{job_name}-#{Time.now.to_i}-#{rand.to_s[2..10]}"
	end

	def set_topics
		$pubsub.list_topics.map{ |topic| topic.name.split("/").last }
	end

	def find_or_create_topic
		create_topic unless topics.include?( job_name )
		$pubsub.topic job_name
	end

	def create_topic
		new_topic =  $pubsub.create_topic( job_name )
		@sub = JobSubscriber.new( new_topic, queue )
		topics << job_name
	end
	
	def set_args( args )
		args[:job_name] = job_name
		args[:publisher_name] = publisher_name
		args
	end
end