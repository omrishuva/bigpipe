module ActiveJob
  module QueueAdapters
    class PubSubQueueAdapter

      def self.pubsub
        $pubsub
      end

      def self.enqueue( job )
        topic = find_or_create_topic( job.class.name, job.queue_name )
        topic.publish( job.job_id, job.arguments[0] )
      end
      
      def self.find_or_create_topic( job_name, queue_name )
        create_topic( job_name, queue_name ) unless topics.include?( job_name )
        $pubsub.topic job_name
      end

      def self.topics
        @@topics ||= $pubsub.list_topics.map{ |topic| topic.name.split("/").last }
      end

      def self.create_topic( job_name, queue_name )
        topic =  $pubsub.create_topic( job_name )
        @@topics = nil
        JobSubscriber.new( topic, queue_name )
      end

      def self.run_worker!( queue_name )
        sub = $pubsub.find_subscription( queue_name )
        sub.listen autoack: true do |message|
          job_class = eval( message.subscription.topic.name.split("/").last )
          job_class.perform_now( message.attributes )
        end
      end

    end
  end
end