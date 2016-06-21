class Sms

	attr_accessor :plivo_api, :sender_number, :destination_numbers, :message_name, :phone_verification_code, :opts, :api_response
	include Plivo

	def initialize( message_name, destination_numbers, opts = { } )
		@opts = opts
		@phone_verification_code = rand.to_s[2..5] if message_name == "phone_verification_message"
		@sender_number = "+972586033370"
		@message_name = message_name
		@destination_numbers = [destination_numbers].flatten
		@plivo_api = init_plivo_api
	end
	
	def send_message
		@api_response = plivo_api.send_message( message_payload )
	end

	def message_payload
		{
			'src' => sender_number,
			'dst' => format_destination_numbers,
			'text' => self.send(message_name)
		}

	end

	def format_destination_numbers
		destination_numbers.join("<")
	end

	def phone_verification_message
		"#{I18n.t(:phone_verification_message)}" + " #{phone_verification_code}"
	end
	
	def init_plivo_api
		auth_id = ENV["plivo_auth_id"] || YAML.load_file("./app.yaml")["env_variables"]["pipedrive_api_key"]
		auth_token = ENV["plivo_auth_token"] || YAML.load_file("./app.yaml")["env_variables"]["plivo_auth_token"]
		RestAPI.new(auth_id, auth_token)
	end

end