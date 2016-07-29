class Geocoder
	API_KEY = ENV["google_api_key"] || YAML.load_file("./app.yaml")["env_variables"]["google_api_key"]
	def initialize
		api_key = ENV["google_api_key"] || YAML.load_file("./app.yaml")["env_variables"]["google_api_key"]

	end

end