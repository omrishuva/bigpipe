class PubsubUtils
	
	class << self
		
		def delete_topic( name )
			topic = $pubsub.topic( name )
			topic.delete if topic
		end
		
		def delete_all_topics
			get_all_topics.each{ |topic| topic.delete }
		end

		def delete_subscription( name )
			sub = $pubsub.get_subscription( name )
			sub.delete if sub
		end

		def delete_all_subscriptions
			get_all_subscriptions.each{ |sub| sub.delete }
		end

		def get_all_topic_names
			get_all_topics.map{|topic| topic.name.split('/').last  }
		end

		def get_all_topics
			$pubsub.list_topics
		end

		def get_all_subscription_names
			get_all_subscriptions.map{|topic| topic.name.split('/').last  }
		end

		def get_all_subscriptions
			$pubsub.list_subscriptions
		end

	end


end