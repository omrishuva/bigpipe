$job_listeners = PubsubUtils.get_all_subscriptions

scheduler = Rufus::Scheduler.new

scheduler.every "2s" do
	$job_listeners.each do |listener|
		jobs = listener.pull
		jobs.each do |job|
			$stderr.puts attributes = job.message.attributes
			$stderr.puts JobRunner.new( attributes )			
			$stderr.puts job.acknowledge!
		end
	end

end