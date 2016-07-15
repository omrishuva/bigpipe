class WidgetsController < ApplicationController
	
	def textbox
		@object = get_object
		@object.update(params[:widget][:fieldName] => params[:widget][:data] ) if params[:widget][:action] == "save"
		respond_to do |format|
      format.js { }
    end
	end

	def get_object
		return current_user if params[:widget][:objectName] == "users"
		eval( params[:widget][:objectName].classify ).find( params[:widget][:objectId] )
	end

end