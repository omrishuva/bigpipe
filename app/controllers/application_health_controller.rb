class ApplicationHealthController < ApplicationController
	
	def health
		render :json => params
	end
end