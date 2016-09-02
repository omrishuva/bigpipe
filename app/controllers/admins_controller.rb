class AdminsController < ApplicationController
	
	def create_site_text
		@site_text = SiteText.new( locale: I18n.locale.to_s, created_by: current_user.id, updated_by: current_user.id ) 
		@site_text.save
	end
	
	def edit_site_text
		@site_text = SiteText.find(params[:id])
	end

	def site_text_index
		@site_texts = SiteText.all
	end

	

end