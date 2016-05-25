
def define_env
	if ENV["GAE_MODULE_VERSION"] && ENV["GAE_MODULE_VERSION"].split("-")[0] == "master" 
		"production"
	elsif ENV["GAE_MODULE_VERSION"] && ENV["GAE_MODULE_VERSION"].split("-")[0] != "master" 
		"staging"
	else
		"development"
	end
end

ENV["RAILS_ENV"] = define_env unless ENV["RAILS_ENV"] == "test"

require File.expand_path("../application", __FILE__)
# Initialize the Rails application.
Rails.application.initialize!