def define_env
	if ENV["GAE_MODULE_VERSION"] && ENV["GAE_MODULE_VERSION"].split("-")[0] == "master" 
		"production"
	else
		"staging"
	end
end

ENV["RAILS_ENV"] = define_env

require File.expand_path("../application", __FILE__)
# Initialize the Rails application.
Rails.application.initialize!


