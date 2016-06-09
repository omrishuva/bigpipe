$job_listeners = PubsubUtils.get_all_subscriptions

scheduler = Rufus::Scheduler.new

scheduler.every "2s" do
	$job_listeners.each do |listener|
		jobs = listener.pull
		jobs.each do |job|
			job.acknowledge!
			attributes = job.message.attributes
			begin
				JobRunner.new( attributes )			
			rescue => e
				logger.info "app_log #{e.message} ---- #{e.backtrace}"
      	$stderr.puts "app_log #{e.message} ---- #{e.backtrace}"
      	$stdout.puts "app_log #{e.message} ---- #{e.backtrace}"
			end
		end
	end

end