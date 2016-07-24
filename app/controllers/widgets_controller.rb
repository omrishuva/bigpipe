class WidgetsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [ :image_widget_control, :text_widget_control ]

	#Text#####################################################

	def text_widget_control
		@object = get_object( params[:objectName], params[:objectId] )
		@object.update(params[:key] => params[:data].to_s.strip ) if params[:state] == "save"
		@widget_data = prepare_text_widget_data
		
		respond_to do |format|
      format.js { }
    end
	
	end
	
	def prepare_text_widget_data
		{
			widgetName: params[:widgetName],
			elementName: params[:elementName],
			objectName: @object.class.name.downcase.pluralize, 
			objectId: @object.id,
			key: params[:key],
			value: @object.send( params[:key] ),
			state: params[:state],
			isWidgetOwner: is_widget_owner,
			placeholder: params[:placeholder],
			editableOverlayText: params[:editableOverlayText],
			textClass: params[:textClass],
			buttonClass: params[:buttonClass]
		}
	end
	
	#Image#####################################################

	def image_widget_control
    
    temp_widget_data = parse_image_image_widget_data
    @object = get_object( temp_widget_data[:objectName], temp_widget_data[:objectId] )
    @object.upload_image( params[:image].tempfile, temp_widget_data[:key] )
    @widget_data = prepare_image_widget_data( temp_widget_data )
    respond_to do |format|
      format.js { }
    end
  
  end
  
  def parse_image_image_widget_data
  	JSON.parse( params[:widget] ).with_indifferent_access
  end

  def prepare_image_widget_data( image_widget_data )
		{
			widgetName: image_widget_data[:widgetName],
			elementName: image_widget_data[:elementName],
			objectName: @object.class.name.downcase.pluralize, 
			objectId: @object.id, 
			key: image_widget_data[:key],
			value: @object.send( image_widget_data[:key] ),
			isWidgetOwner: is_widget_owner,
			overlayText: image_widget_data[:overlayText],
			placeholder: image_widget_data[:placeholder],
			editableOverlayText: image_widget_data[:editableOverlayText]
		}
	end

  #Utilities#####################################################

  def get_object( object_name, object_id )
		return current_user if object_name == "users" && current_user.id.to_s == params[:objectId]
		eval( object_name.classify ).find( object_id )
	end

	def is_widget_owner
		@object.owners.map(&:to_s).include?( current_user.try(:id).to_s )
	end

	######################################################
end