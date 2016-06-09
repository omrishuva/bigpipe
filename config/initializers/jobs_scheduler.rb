$job_listeners = PubsubUtils.get_all_subscriptions

scheduler = Rufus::Scheduler.new

scheduler.every "2s" do
	$job_listeners.each do |listener|
		jobs = listener.pull
		jobs.each do |job|
			Rails.logger.info attributes = job.message.attributes
			Rails.logger.info JobRunner.new( attributes )
			Rails.logger.info job.acknowledge!
		end
	end

end