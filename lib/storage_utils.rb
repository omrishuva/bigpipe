module StorageUtils
	
	def save_file( file, key, bucket_name, opts = { } )
		bucket = find_or_create_bucket( bucket_name )
		file = bucket.create_file( file, key )
		file.acl.public_read! if opts[:public] == true
		file
	end
	
	private

	def find_or_create_bucket( bucket_name )
		$storage.find_bucket( "#{Rails.env}_#{bucket_name}" ) || $storage.create_bucket( "#{Rails.env}_#{bucket_name}")
	end

end