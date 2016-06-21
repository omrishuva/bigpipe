if Rails.env == "development"
	Pipedrive.authenticate( YAML.load_file("./app.yaml")["env_variables"]["pipedrive_api_key"] )
else
	Pipedrive.authenticate( ENV["pipedrive_api_key"] )
end