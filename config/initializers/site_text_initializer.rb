def generate_site_text_hash
	site_texts_object = SiteText.all
	site_text_hash = { }
	
	site_texts_object.each do |t|
		site_text_hash[t.generate_key] = t.text
	end
	site_text_hash
end
$site_text = generate_site_text_hash