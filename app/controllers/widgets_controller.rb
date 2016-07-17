class WidgetsController < ApplicationController
	
	def text_area_box
		@object = get_object
		@object.update(params[:widget][:key] => params[:widget][:data].strip ) if params[:widget][:state] == "save"
		@widget_data = prepare_widget_data
		respond_to do |format|
      format.js { }
    end
	end

	def get_object
		return current_user if params[:widget][:objectName] == "users"
		eval( params[:widget][:objectName].classify ).find( params[:widget][:objectId] )
	end
	
	def prepare_widget_data
		{
			objectName: @object.class.name.downcase.pluralize, 
			objectId: @object.id, 
			key: params[:widget][:key],
			value: @object.send( params[:widget][:key] ),
			state: params[:widget][:state],
			isWidgetOwner: @object.owners.include?( current_user.try(:id) ),
			placeholder: params[:widget][:placeholder]
		}
	end

end