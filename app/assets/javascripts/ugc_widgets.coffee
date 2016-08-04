$(document).ready ->
	loadWidgets();

document.addEventListener 'loadWidgetListeners',(e) ->
  loadWidgets();

loadWidgets = ->
	initCheckbox();
	widgetControls = $('.widgetControl')
	if widgetControls.length > 0
		for widgetControl in widgetControls
		 	selectorKey = buildWidgetSelectorKey( widgetControl.dataset )
		 	switch widgetControl.dataset.widgetName  
		 		when "text_area_box" 
		 			textWidgetControl( selectorKey )
		 		when	"text_input_box"
		 			textWidgetControl( selectorKey )
		 		when	"multiple_select_box"
		 			textWidgetControl( selectorKey )
		 		when "image_box"
			 		imageWidgetControl( selectorKey )
			 	when "location"
			 		locationWidgetControl( selectorKey )



buildWidgetSelectorKey = ( widgetData) ->
	"##{widgetData.objectId}.widgetControl[data-element-name='#{widgetData.elementName}'][data-key='#{widgetData.key}']"

widgetId = ( widget ) ->
	"#{widget.objectId}_#{widget.key}"

inputId = ( widget ) ->				
	"input_#{widgetId(widget)}"

initCheckbox = ->
	$("[name='publish-activity']").bootstrapSwitch();
	checkBoxWidgetControl();

checkBoxWidgetControl = ->
	$('input[name="publish-activity"]').on 'switchChange.bootstrapSwitch', (event, state) ->
	  console.log this
	  console.log event
	  console.log state
  
  
  

textWidgetControl =( selectorKey ) ->
	$( selectorKey ).click (e) ->
	  widget = {}
	  widget = Object.assign({}, e.target.dataset )
	  requestMethod = 'GET'
	  switch widget.state
	  	when 'cancel'
	  		textWidgetControlCancel( widget ) 
	  	when 'save'
		  	requestMethod = 'POST'
		  	widget = textWidgetControlSave( widget )
		  	console.log( widget['data'] )
	  $.ajax
	    type: requestMethod
	    url: "/widgets/text_widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget
   		success: (data) ->
      	textWidgetControl( selectorKey );
      	$(".select2").select2({ theme: "bootstrap",  'maximumSelectionLength': parseInt(widget.maxSelections) });

textWidgetControlSave = ( widget ) ->
	switch widget.widgetName
		when "text_area_box"
			widget['data'] = CKEDITOR.instances["editor#{inputId( widget )}"].getData()
		when "text_input_box"
			widget['data'] = $("##{inputId(widget)}").val()
		when "multiple_select_box"
			widget['data'] = $("##{inputId(widget)}").val()
	widget

textWidgetControlCancel = ( widget ) ->
	if widget.widgetName == "text_area_box"
		CKEDITOR.instances["editor#{inputId(widget)}"].destroy()
		$( "##{ widgetId(widget) }.textAreaBox" ).hide();

imageWidgetControl = ( selectorKey ) ->
  $( selectorKey ).change (e) ->
    formData = new FormData;
    file = e.target.files[0];
    widget = e.target.dataset;
    formData.append( 'image', file, file.name );
    formData.append( 'widget', JSON.stringify(widget) );
    initUploadImageLoader(widget);
    $.ajax
        type: 'POST'
        url: "/widgets/image_widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
        data: formData
        processData: false
        contentType: false
        success: (data) ->
          imageWidgetControl( selectorKey );

initUploadImageLoader = ( widget ) ->
	$('.fa-camera').addClass('fa-spin');
	$("##{widget.objectId}updateCoverImageText").text("Updating Image")

locationWidgetControl = ( selectorKey ) ->
	$( selectorKey ).click (e) ->
		widget = e.target.dataset
		widget['loadScriptAfterServerResponse'] = true
		shouldSendRequest = true
		switch widget.state
	  	when 'cancel'
	  		widget['loadScriptAfterServerResponse'] = false
	  		textWidgetControlCancel( widget ) 
	  	when 'save'
		  	requestMethod = 'POST'
		  	widget['data'] = getPlaceid(); 	
		  	widget['loadScriptAfterServerResponse'] = false
		  	if !getPlaceid()
				  window.alert( "Please choose a location for your activity before saving" );
				  shouldSendRequest = false
					
		if shouldSendRequest
			$.ajax
		    type: requestMethod
		    url: "/widgets/location_widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
		    data: widget
	   		success: (data) ->
	      	locationWidgetControl( selectorKey );

getPlaceid = ->
	currentPlace.place_id if currentPlace







