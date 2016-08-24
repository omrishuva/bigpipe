class WidgetsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [ :multiple_state_widget_control ]

	def multiple_state_widget_control
		case params[:widgetName]
			when "text_area_box" then base_widget
			when "text_input_box" then base_widget
			when "multiple_select_box" then base_widget
			when "slider_box" then base_widget
			when "checkbox_box" then base_widget
			when "wizard_buttons" then base_widget
			when "image_box" then image_widget
			when "location" then location_widget
			when "scheduling_box" then scheduling_widget
		end
		
		respond_to do |format|
      format.js { }
    end

	end

	#Base Widgt#####################################################

	def base_widget
		@object = get_object( params[:objectName], params[:objectId] )
		save_value if params[:state] == "save"
		@widget_data = prepare_base_widget_data
		# @next_widget_data = prepare_next_widget_data if params[:followed_action] && params[:followed_action][:render_wizard]
	end

	def save_value
		if params[:dataType] == "StringArray"
			value = params[:data].split(",")
		elsif  params[:dataType] == "Integer"
			value = params[:data].to_i
		elsif params[:dataType] == "Float"
			value = params[:data].to_f
		elsif params[:dataType] == "Array"
			value = params[:data]
		else
			value = params[:data].to_s.strip
		end
		@object.update( params[:key] => value )
	end

	def prepare_base_widget_data
		{
			widgetName: params[:widgetName],
			elementName: params[:elementName],
			objectName: @object.class.name.downcase.pluralize, 
			objectId: @object.id,
			key: params[:key],
			value: @object.send( params[:key] ),
			dataType: params[:dataType],
			state: params[:state],
			selectOptions: (params[:selectOptions].map{|k,v| v } rescue nil ),
			isWidgetOwner: is_widget_owner,
			placeholder: params[:placeholder],
			placeholderClass: params[:placeholderClass],
			editableOverlayText: params[:editableOverlayText],
			textClass: params[:textClass],
			buttonClass: params[:buttonClass],
			maxSelections: params[:maxSelections],
			maxValue: params[:maxValue],
			sliderSteps: params[:sliderSteps],
			parentNode: ( params[:parentNode].merge( value: params[:value] ) rescue nil )
		}.delete_if { |k, v| !v.present? }
	end
	
	#Image#####################################################

	def image_widget
    temp_widget_data = parse_image_image_widget_data
    @object = get_object( temp_widget_data[:objectName], temp_widget_data[:objectId] )
    @object.upload_image( params[:image].tempfile, temp_widget_data[:key] )
    @widget_data = prepare_image_widget_data( temp_widget_data )
  end
  
  def parse_image_image_widget_data
  	temp = JSON.parse( params[:widget] ).with_indifferent_access
  	temp
  end

  def prepare_image_widget_data( image_widget_data )
		{
			widgetName: image_widget_data[:widgetName],
			elementName: image_widget_data[:elementName],
			objectName: @object.class.name.downcase.pluralize, 
			objectId: @object.id, 
			key: image_widget_data[:key],
			value: @object.send( image_widget_data[:key] ),
			imageWidth: image_widget_data[:imageWidth],
			imageHeight: image_widget_data[:imageHeight],
			imageCrop: image_widget_data[:imageCrop],
			imageGravity: image_widget_data[:imageGravity],
			imageTagClass: image_widget_data[:imageTagClass],
			imageTagId: image_widget_data[:imageTagId],
			isWidgetOwner: is_widget_owner,
			overlayText: image_widget_data[:overlayText],
			placeholder: image_widget_data[:placeholder],
			editableOverlayText: image_widget_data[:editableOverlayText]
		}.delete_if { |k, v| !v.present? }
	end
	#Location#####################################################
	
	def location_widget
		@object = get_object( params[:objectName], params[:objectId] )
		@object.update(params[:key] => params[:data] ) if params[:state] == "save"
		@widget_data = prepare_location_widget_data
	end
	
	def prepare_location_widget_data
		{
			widgetName: params[:widgetName],
			elementName: params[:elementName],
			objectName: @object.class.name.downcase.pluralize, 
			objectId: @object.id, 
			key: params[:key],
			value: @object.send( params[:key] ),
			state: params[:state],
			isWidgetOwner: is_widget_owner,
			loadScriptAfterServerResponse: params[:loadScriptAfterServerResponse],
			placeholder: params[:placeholder]
		}.delete_if { |k, v| !v.present? }
	end
	#Scheduling####################################################

	def scheduling_widget
		@object = get_object( params[:objectName], params[:objectId] )
		@object.save_scheduling_configuration( params ) if params[:state] == "save"
		@widget_data = prepare_schedling_widget_data
	end

	def prepare_schedling_widget_data
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
			placeholderClass: params[:placeholderClass],
			textClass: params[:textClass],
			buttonClass: params[:buttonClass],
			schedulingType: params[:schedulingType],
			object: @object
		}.delete_if { |k, v| !v.present? }
	end
	
	#Wizard########################################################

	def wizard

	end

  #Utilities#####################################################

  def get_object( object_name, object_id )
		return current_user if object_name == "users" && current_user_id.to_s == params[:objectId]
		eval( object_name.classify ).find( object_id )
	end

	def is_widget_owner
		return true if @object.class.name == "User" && ( @object.id == current_user_id  || current_user.super_admin?  )
		current_user.can_edit_account?
		# @object.account.is_editor?( current_user )
	end
	
	######################################################
end