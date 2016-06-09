class JobPublisher
  	
  	attr_accessor :topics, :publisher_name, :job_name, :job_id, :args

  	def initialize( publisher_name, job_name, args = { } )
  		@publisher_name = publisher_name
  		@job_name =  "#{Rails.env}-#{publisher_name}-#{job_name}"
  		@topics = set_topics
  		@topic = find_or_create_topic
  		@job_id = generate_job_id
  		@args = args
  	end

		def publish
			topic.publish( job_id, args  )
		end
		
		private
		
		def generate_job_id
			"#{job_name}-#{Time.now.to_i}-#{rand.to_s[2..10]}"
		end

		def set_topics
			$pubsub.list_topics.map{|topic| topic.name.split("/").last }
		end

		def find_or_create_topic
			create_topic unless topics.include?( job_name )
			$pubsub.topic job_name
		end

		def create_topic
			new_topic =  $pubsub.create_topic( job_name )
			new_topic.new_subscription "#{job_name}-subscription"
			topics << job_name
		end

end