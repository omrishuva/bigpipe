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

widgetId = ( widget ) ->
	"#{widget.objectId}_#{widget.key}"

inputId = ( widget ) ->				
	"input_#{widgetId(widget)}"
											
textWidgetControl =( selectorKey ) ->
	$( selectorKey ).click (e) ->
	  widget = {}
	 	widget = getDataset( e.target )
	  requestMethod = 'GET'
	  switch widget.state
	  	when 'cancel'
	  		textWidgetControlCancel( widget ) 
	  	when 'save'
		  	requestMethod = 'POST'
		  	widget = textWidgetControlSave( widget )
	  $.ajax
	    type: requestMethod
	    url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget
   		success: (data) ->
      	textWidgetControl( selectorKey );

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
    localStorage.setItem(selectorKey, widget.nestedWidgetSelectorKey)
    $.ajax
        type: 'POST'
        url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
        data: formData
        processData: false
        contentType: false
        success: (data) ->
        	if localStorage["#{selectorKey}"]
	        	textWidgetControl( localStorage["#{selectorKey}"] )
	        	localStorage.setItem(selectorKey, null)
          imageWidgetControl( selectorKey );

initUploadImageLoader = ( widget ) ->
	$('.fa-camera').addClass('fa-spin');
	$("##{widget.objectId}updateCoverImageText").text("Updating Image")

locationWidgetControl = ( selectorKey ) ->
	$( selectorKey ).click (e) ->
		widget = getDataset( e.target )
		widget['loadScriptAfterServerResponse'] = true
		shouldSendRequest = true
		switch widget.state
	  	when 'edit'
	  		widget['loadScriptAfterServerResponse'] = false
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
		    url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
		    data: widget
	   		success: (data) ->
	      	locationWidgetControl( selectorKey );

getPlaceid = ->
	currentPlace.place_id if currentPlace

getDataset = ( el ) ->
	if el.className == "buttonText"
	 el.parentElement.dataset
	else
	 el.dataset


