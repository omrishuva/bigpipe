$(document).ready ->
	loadWidgets();

document.addEventListener 'loadWidgetListeners',(e) ->
  loadWidgets();

loadWidgets = ->
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

textWidgetControl =( selectorKey ) ->
	$( selectorKey ).click (e) ->
	  widget = {}
	  widget = e.target.dataset
	  requestMethod = 'GET'
	  switch widget.state
	  	when 'cancel'
	  		textWidgetControlCancel( widget ) 
	  	when 'save'
		  	requestMethod = 'POST'
		  	widget['data'] = textWidgetControlSave( widget )
	  $.ajax
	    type: requestMethod
	    url: "/widgets/text_widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget
   		success: (data) ->
      	textWidgetControl( selectorKey );
      	$(".select2").select2({ theme: "bootstrap"});

textWidgetControlSave = ( widget ) ->
	if widget.widgetName == "text_area_box"
		CKEDITOR.instances["editor#{widget.objectId}"].getData()
	else
		$("input[name='#{widget.widgetName}']").val()

textWidgetControlCancel = ( widget ) ->
	if widget.widgetName == "text_area_box"
		CKEDITOR.instances["editor#{widget.objectId}"].destroy()
		$( "##{widget.objectId}_#{widget.key}.textAreaBox" ).hide();

imageWidgetControl = ( selectorKey ) ->
  $( selectorKey ).change (e) ->
    formData = new FormData;
    file = e.target.files[0];
    widget = e.target.dataset;
    formData.append( 'image', file, file.name );
    formData.append( 'widget', JSON.stringify(widget) );
    initUploadImageLoader();
    $.ajax
        type: 'POST'
        url: "/widgets/image_widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
        data: formData
        processData: false
        contentType: false
        success: (data) ->
          imageWidgetControl( selectorKey );

initUploadImageLoader = ->
	cameraIcon = $('.fa-camera');
	cameraIcon.text("");
	cameraIcon.addClass('fa-spin');

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







