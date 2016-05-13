class ApplicationHealthController < ApplicationController
	
	def start
		render :json => params
	end

	def health
		render :json => params
	end
end