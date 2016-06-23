if Rails.env == "production"
	pd_api_key = ENV["pipedrive_api_key"]
else
	pd_api_key = YAML.load_file("./app.yaml")["env_variables"]["pipedrive_api_key"]
end
Pipedrive.authenticate( pd_api_key )