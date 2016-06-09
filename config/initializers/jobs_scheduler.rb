$job_listeners = PubsubUtils.get_all_subscriptions

scheduler = Rufus::Scheduler.new

scheduler.every "2s" do
	$job_listeners.each do |listener|
		jobs = listener.pull
		jobs.each do |job|
			job.acknowledge!
			attributes = job.message.attributes
			JobRunner.new( attributes )			
		end
	end

end