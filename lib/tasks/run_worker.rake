desc "Run task queue worker"

task run_worker: :environment do
	Rails.logger.info " Running Worker"
	ActiveJob::QueueAdapters::PubSubQueueAdapter.run_worker!("#{Rails.env}-now")
end