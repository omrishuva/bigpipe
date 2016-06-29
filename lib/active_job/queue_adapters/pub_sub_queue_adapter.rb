module ActiveJob
  module QueueAdapters
    class PubSubQueueAdapter

      def self.pubsub
        $pubsub
      end

      def self.enqueue( job )
        topic_name = "#{Rails.env}-#{job.queue_name}"
        queue_name = "#{Rails.env}-#{job.queue_name}"
        arguments = job.arguments[0]
        arguments[:class] = job.class.name
        topic = find_or_create_topic(topic_name, queue_name )
        topic.publish( job.job_id, arguments )
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
          p message.subscription.topic.name.split("-").last.split("/").last
          job_class = eval( message.attributes["class"] )
          p "#{queue_name} -> #{job_class.to_s} -> #{ message.attributes } "
          Rails.logger.info "#{queue_name} -> #{job_class.to_s} -> #{ message.attributes } "
          job_class.perform_now( message.attributes )
        end
      end

    end
  end
end