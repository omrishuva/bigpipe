document.addEventListener 'loadButton',(e) ->
	widgetData = e.detail.widgetData;
	addDataAttributesToButton( widgetData );

addDataAttributesToButton = ( widgetData ) ->
	$("##{widgetData.id}").data( widgetData: widgetData );
	loadWidget( widgetData )

loadWidget = ( widgetData ) ->
 	if widgetData.wizardConf
 		widgetName = widgetData.wizardConf.widgetName
 	else
 		widgetName = widgetData.widgetName
 	id = widgetData.id
 	switch widgetName
 		when "text_area_box" 
 			baseWidgetControl( id );
 		when	"text_input_box"
 			baseWidgetControl( id );
 		when	"multiple_select_box"
 			baseWidgetControl( id );
 		when "slider_box"
	 		baseWidgetControl( id );
 		when 'wizard_buttons'
	 		baseWidgetControl( id );
	 	when "checkbox_box"
	 		baseWidgetControl( id );
	 	when "account_setup"
	 		baseWidgetControl( id );
	 	when "activity_setup"
	 		baseWidgetControl( id );
	 	when "trip_request_setup"
	 		baseWidgetControl( id );
 		when "image_box"
	 		imageWidgetControl( id );
	 	when "location"
	 		locationWidgetControl( id );
	 	when "scheduling_box"
	 		schedulingWidgetControl( id );

buildWidgetSelectorKey = ( widgetData) ->
	"##{widgetData.objectId}.widgetControl[data-element-name='#{widgetData.elementName}'][data-key='#{widgetData.key}']"

widgetId = ( widget ) ->
	"#{widget.objectId}_#{widget.key}"

inputId = ( widget ) ->				
	"input_#{widgetId(widget)}"
											
baseWidgetControl =( id ) ->
	$( "##{id}" ).click (e) ->
	  widget = {}
	 	widget = getDataset( e.target )
	  requestMethod = 'GET'
	  switch widget.state
	  	when 'cancel'
	  		baseWidgetControlCancel( widget )
	  		widget.value = ""
	  	when 'edit'
	  		widget.value = ""
	  	when 'save'
		  	requestMethod = 'POST'
		  	widget = baseWidgetControlSave( widget )
	  $.ajax
	    type: requestMethod
	    url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget
   		
baseWidgetControlSave = ( widget ) ->
	switch widget.widgetName
		when "text_area_box"
			widget['data'] = CKEDITOR.instances["editor#{inputId( widget )}"].getData()
		when "text_input_box"
			widget['data'] = $("##{inputId(widget)}").val()
		when "multiple_select_box"
			widget['data'] = $("##{inputId(widget)}").val()
		when 'slider_box'
			widget['data'] = $("##{inputId(widget)}").val()
		when "checkbox_box"
			widget['data'] = getCheckboxSelectedValue();
		when 'wizard_buttons'
			widget['data'] = widget.value
	widget

baseWidgetControlCancel = ( widget ) ->
	if widget.widgetName == "text_area_box"
		CKEDITOR.instances["editor#{inputId(widget)}"].destroy()
		$( "##{ widgetId(widget) }.textAreaBox" ).hide();

getCheckboxSelectedValue = ->
	options = $('input[type="radio"]')
	for option in options
		return option.value if option.checked == true

imageWidgetControl = ( id ) ->
  $( "##{id}" ).change (e) ->
    formData = new FormData;
    file = e.target.files[0];
    widget = getDataset( e.target);
    formData.append( 'image', file, file.name );
    formData.append( 'widget', JSON.stringify(widget) );
    initUploadImageLoader(widget);
    $.ajax
        type: 'POST'
        url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
        data: formData
        processData: false
        contentType: false
        
        	
initUploadImageLoader = ( widget ) ->
	$('.fa-camera').addClass('fa-spin');
	$("##{widget.id}updateCoverImageText").text("Updating Image")

locationWidgetControl = ( id ) ->
	$( "##{id}" ).click (e) ->
		widget = getDataset( e.target )
		widget['loadScriptAfterServerResponse'] = true
		shouldSendRequest = true
		switch widget.state
	  	when 'edit'
	  		widget['loadScriptAfterServerResponse'] = false
	  	when 'cancel'
	  		widget['loadScriptAfterServerResponse'] = false
	  		# locationWidgetControl( widget ) 
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

getPlaceid = ->
	currentPlace.place_id if currentPlace

schedulingWidgetControl = ( id ) ->
	$( "##{id}" ).click (e) ->
		widget = getDataset( e.target )
		widget = schedulingWidgetSave( widget ) if widget.state == "save"
		$.ajax
	    type: "POST"
	    url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget

schedulingWidgetSave = ( data ) ->
	switch data.schedulingType
    when "recurringEvent"
      data = saverecurringEvent( data );
    when "specificDates"
      data = saveSpecificDate( data );
  data['activityLeader'] = getActivityLeader( data );
  data

saverecurringEvent = (data) ->
  data['selectedTime'] = $('.dateTimePicker').data('date');
  data['selectedDayOfWeek'] = $('#dayOfWeek').val();
  data

saveSpecificDate = (data) ->
  data['selectedDate'] =  new Date( $('.dateTimePicker').data('date') )
  data  

getActivityLeader = (data) ->
  activityLeaders = $('#activityLeader').val();

#Utilities###############################################################################################
getDataset = ( el ) ->
	if el.className == "buttonText"
	 id = el.parentElement.id
	else
	 id = el.id
	$("##{id}").data('widgetData')


