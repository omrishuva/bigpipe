class WidgetsController < ApplicationController
	
	def widget_control
		@object = get_object
		@object.update(params[:key] => params[:data].strip ) if params[:state] == "save"
		@widget_data = prepare_widget_data
		respond_to do |format|
      format.js { }
    end
	end

	def get_object
		return current_user if params[:objectName] == "users"
		eval( params[:objectName].classify ).find( params[:objectId] )
	end
	
	def prepare_widget_data
		{
			widgetName: params[:widgetName],
			elementName: params[:elementName],
			objectName: @object.class.name.downcase.pluralize, 
			objectId: @object.id, 
			key: params[:key],
			value: @object.send( params[:key] ),
			state: params[:state],
			isWidgetOwner: is_widget_owner,
			placeholder: params[:placeholder]
		}
	end

	def is_widget_owner
		 @object.owners.include?( current_user.try(:id) )
	end

end