class Sms

	attr_accessor :plivo_api, :sender_number, :destination_numbers, :message_name, :phone_verification_code, :opts, :api_response
	include Plivo

	def initialize( message_name, destination_numbers, opts = { } )
		auth_id = "MAMZK2YJM5NDKYNDUZZD"
		auth_token = "NDc0NmJmOWIyMWM5Y2RmMjhkMjVkYTUzY2RhMGJj"
		@opts = opts
		@phone_verification_code = rand.to_s[2..5] if message_name == "phone_verification_message"
		@sender_number = 97236033370
		@message_name = message_name
		@destination_numbers = [destination_numbers].flatten
		@plivo_api = RestAPI.new(auth_id, auth_token)
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
		"Hi #{opts[:name]} welcome to Play, please enter the following code #{phone_verification_code}"
	end

end