class WidgetsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [:image_widget_control]

	#Text#####################################################

	def text_widget_control
		@object = get_object( params[:objectName], params[:objectId] )
		@object.update(params[:key] => params[:data].strip ) if params[:state] == "save"
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
			placeholder: params[:placeholder]
		}
	end
	
	#Image#####################################################

	def image_widget_control
    image_widget_data = parse_image_image_widget_data
    cloudinary_image = Cloudinary::Uploader.upload( params[:image].tempfile, eager:{ width: 700, height: 400, crop: :thumb, gravity: :face } )
    image_widget_data[:value] = cloudinary_image["public_id"]
   	@object = get_object( image_widget_data[:objectName], image_widget_data[:objectId])
    @widget_data = prepare_image_widget_data( image_widget_data )
    @object.update( @widget_data[:key] => cloudinary_image["public_id"] )    
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
			value: image_widget_data[:value],
			isWidgetOwner: is_widget_owner,
			overlayText: image_widget_data[:overlayText],
			placeholder: image_widget_data[:placeholder]

		}
	end

  #Utilities#####################################################

  def get_object( object_name, object_id )
		return current_user if object_name == "users"
		eval( object_name.classify ).find( object_id )
	end

	def is_widget_owner
		 @object.owners.include?( current_user.try(:id) )
	end

	######################################################
end