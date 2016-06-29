class JobSubscriber
	
	attr_accessor :topic, :queue, :sub

	def initialize( topic, queue )
		@topic = topic
		@queue = queue
		# PubsubUtils.delete_subscription( queue )
		@sub = topic.subscribe( queue )
	end
	
end