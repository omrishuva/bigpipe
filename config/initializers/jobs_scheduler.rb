logger.info $job_listeners = PubsubUtils.get_all_subscriptions

scheduler = Rufus::Scheduler.new

scheduler.every "2s" do
	$job_listeners.each do |listener|
		logger.info.puts listener
		jobs = listener.pull
		logger.info.puts jobs
		jobs.each do |job|
			logger.info attributes = job.message.attributes
			logger.info JobRunner.new( attributes )			
			logger.info job.acknowledge!
		end
	end

end