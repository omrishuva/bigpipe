class WidgetsController < ApplicationController

	skip_before_action :verify_authenticity_token, only: [ :widget_control ]

	def widget_control
		if params[:wizard] == "true"
			wizard_widget
		else
			case widget_name
				when "text_area_box" then base_widget
				when "text_input_box" then base_widget
				when "multiple_select_box" then base_widget
				when "slider_box" then base_widget
				when "plus_minus_box" then base_widget
				when "checkbox_box" then base_widget
				when "datetime_box" then base_widget
				when "date_range_box" then base_widget
				when "image_box" then image_widget
				when "location" then location_widget
				when "scheduling_box" then scheduling_widget
				when "account_setup" then wizard_widget
				when "trip_request_setup" then wizard_widget
			end
		end
		respond_to do |format|
      format.js { }
    end
	end

	def widget_name
		params[:wizardConf].present? ? params[:wizardConf][:widgetName] : params[:widgetName]
	end

	#Base Widgt#####################################################

	def base_widget
		@object = get_object( params[:objectName], params[:objectId] )
		save_value if params[:state] == "save"
		@widget_data = prepare_base_widget_data
	end

	def save_value
		if params[:data]
			key = params[:saveKey] || params[:key]
			if params[:dataType] == "StringArray"
				value = params[:data].split(",")
			elsif  params[:dataType] == "Integer"
				value = params[:data].to_i
			elsif params[:dataType] == "Float"
				value = params[:data].to_f
			elsif params[:dataType] == "Array"
				value = params[:data]
			elsif params[:dataType] == "compressedText"
				compressed_text = Zlib::Deflate.deflate( params[:data] )
				value = Base64.encode64(compressed_text)
				key = :compressed_text
			else
				value = params[:data].to_s.strip
			end
			@object.update( key => value )
		end
	end

	def prepare_base_widget_data
		{
			widgetName: params[:widgetName],
			elementName: params[:elementName],
			objectName: @object.class.name, 
			objectId: @object.id,
			key: params[:key],
			value: get_value,
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
			removePlugins: params[:removePlugins],
			imageOverlay: params[:imageOverlay],
			saveOnly: params[:saveOnly],
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
			objectName: @object.class.name, 
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
			editableOverlayText: image_widget_data[:editableOverlayText],
		}.delete_if { |k, v| !v.present? }
	end
	#Location#####################################################
	
	def location_widget
		@object = get_object( params[:objectName], params[:objectId] )
		if params[:state] == "save"
			place = Place.find_by_owner_and_key( params[:objectName],  params[:objectId], params[:key]  )
			# if place
			# 	place.update( place_id: params[:data] ) if place.place_id != params[:data]
			# else
				place = Place.new( place_id: params[:data], owner_object_type: params[:objectName], owner_object_id: params[:objectId], place_key: params[:key] )
				place.save
			# end
		end
		@widget_data = prepare_location_widget_data
	end
	
	def prepare_location_widget_data
		{
			widgetName: params[:widgetName],
			elementName: params[:elementName],
			objectName: @object.class.name, 
			objectId: @object.id, 
			key: params[:key],
			value: @object.send( params[:key] ),
			state: params[:state],
			isWidgetOwner: is_widget_owner,
			loadScriptAfterServerResponse: params[:loadScriptAfterServerResponse],
			saveOnly: params[:saveOnly],
			mapId: params[:mapId],
			loadMapAndSearchBox: params[:loadMapAndSearchBox],
			widgetMode: params[:widgetMode],
			placeholder: params[:placeholder],
		}.delete_if { |k, v| !v.present? }
	end
	#Scheduling####################################################

	def scheduling_widget
		@object = get_object( params[:objectName], params[:objectId] )
		@object.save_scheduling_configuration( params ) if params[:state] == "save"
		@widget_data = prepare_scheduling_widget_data
	end

	def prepare_scheduling_widget_data
		{
			widgetName: params[:widgetName],
			elementName: params[:elementName],
			objectName: @object.class.name, 
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
	
	def wizard_widget
		@object = get_object( params[:objectName], params[:objectId] )
		save_value if params[:state] == "save"
		@widget_data = prepare_wizard_data
	end

	def prepare_wizard_data
		{
			wizard: true,
			widgetName: params[:widgetName],
			elementName: params[:elementName],
			objectName: @object.class.name, 
			objectId: @object.id,
			key: params[:key],
			value: get_value,
			nodeNumber: nodeNumber,
			dataType: params[:dataType],
			state: params[:state],
			selectOptions: (params[:selectOptions].map{|k,v| v } rescue nil ),
			isWidgetOwner: is_widget_owner,
			placeholder: $wizards["placeholders"][params[:widgetName]][nodeNumber],
			saveButtonText: $wizards["save_button_text"][params[:widgetName]][nodeNumber],
			placeholderClass: params[:placeholderClass],			
			textClass: params[:textClass],
			replaceDivId: params[:replaceDivId],
			replacePartial: params[:replacePartial],
			buttonClass: params[:buttonClass],
		}.delete_if { |k, v| !v.present? }
	end
	
	def nodeNumber
		if params[:promoteNode] == "false"
			params[:nodeNumber].to_i
		elsif params[:skipNextNode] == "true"
			(params[:nodeNumber].to_i + 2)
		else
			(params[:nodeNumber].to_i + 1)
		end
	end

  #Utilities#####################################################

  def get_object( object_name, object_id )
		return current_user if object_name == "users" && current_user_id.to_s == params[:objectId]
		eval( object_name ).find( object_id )
	end

	def is_widget_owner
		return true if @object.class.name == "User" && ( @object.id == current_user_id  || current_user.super_admin?  )
		true
		# current_user.can_edit_account?
		# @object.account.is_editor?( current_user )
	end
	
	def get_value
		@object.send( params[:key] ) rescue nil
	end

	######################################################
end