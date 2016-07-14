class WidgetsController < ApplicationController
	
	def textbox
		@object = get_object( params[:widget][:objectName], params[:widget][:objectId] )
		@object.update(params[:widget][:fieldName] => params[:widget][:data] ) if params[:widget][:action] == "save"
		respond_to do |format|
      format.js { }
    end
	end

	def get_object( object, obejct_id )
		return current_user if object == "users"
		eval( object.classify ).find( object_id )
	end

end