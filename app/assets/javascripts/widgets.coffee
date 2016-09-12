document.addEventListener 'activateButton',(e) ->
	widgetData = e.detail.widgetData;
	addDataAttributesToButton( widgetData, 'activateButton' );

document.addEventListener 'bindToWizardButton',(e) ->
	widgetData = e.detail.widgetData;
	addDataAttributesToButton( widgetData, 'bindToWizardButton' );

document.addEventListener 'registerWizardOnPage',(e) ->
	widgetData = e.detail.widgetData;
	@registeredWizardOnPage = { }
	@registeredWizardOnPage = widgetId( widgetData )

document.addEventListener 'triggerClickEventInBindedWidgets',(e) ->
	triggerClickEventInBindedWidgets(widget);

document.addEventListener 'submitInputOnChange',(e) ->
	submitInputOnChange( e.detail.input )

addDataAttributesToButton = ( widgetData, activationType ) ->
	$("##{widgetData.id}").data( widgetData: widgetData );
	if activationType == "activateButton"
		activateButton( widgetData )
	if activationType == "bindToWizardButton"
		bindToWizardButton( widgetData );

bindToWizardButton = ( widgetData ) ->
	@bindedWidgets = { } unless @bindedWidgets
	@bindedWidgets[widgetData.nodeNumber] = [] unless @bindedWidgets[widgetData.nodeNumber] 
	@bindedWidgets[widgetData.nodeNumber].push( widgetData.id )

activateButton = ( widgetData ) ->
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
	 	when "plus_minus_box"
	 		baseWidgetControl( id );
 		when 'wizard_buttons'
	 		baseWidgetControl( id );
	 	when "checkbox_box"
	 		baseWidgetControl( id );
	 	when "datetime_box"
	 		baseWidgetControl( id );
	 	when "date_range_box"
	 		baseWidgetControl( id );
 		when "image_box"
	 		imageWidgetControl( id );
	 	when "location"
	 		locationWidgetControl( id );
	 	when "scheduling_box"
	 		schedulingWidgetControl( id );
	 	when "account_setup"
	 		wizardControl( id );
	 	when "activity_setup"
	 		wizardControl( id );
	 	when "trip_request_setup"
	 		wizardControl( id );
	 	when "join_as_expert"
	 		wizardControl( id );

submitInputOnChange = (input) -> 
	button = $("[data-input-id='#{input.id}'][data-state='save'][data-submit-on-change=true]")
	button.trigger('click') if button
	
buildWidgetSelectorKey = ( widgetData) ->
	"##{widgetData.objectId}.widgetControl[data-element-name='#{widgetData.elementName}'][data-key='#{widgetData.key}']"

widgetId = ( widget ) ->
	"#{widget.objectId}_#{widget.key}"

inputId = ( widget ) ->				
	"input_#{widgetId(widget)}"

wizardControl =( id ) ->
	$( "##{id}" ).click (e) ->
	  # $(this).data("widgetData").objectId
	  widgetIdSelector = widgetId( $(this).data("widgetData") )
	  
	  widget = {}
	 	widget = getDataset( e.target )
	 	$("##{widgetIdSelector}").hide() unless widget.replaceDivId
	 	 
	 	if widget.replaceDivId
	 		$('.btnBrand1InverseBgColor').removeClass('btnBrand1InverseBgColor')
	 		$(this).addClass("btnBrand1InverseBgColor");
	 		
	 	$(this).attr('disabled', 'disabled' )
	  requestMethod = 'GET'
	  triggerClickEventInBindedWidgets(widget);
	  switch widget.state
	  	when 'cancel'
	  		baseWidgetControlCancel( widget )
	  		widget.value = ""
	  	when 'edit'
	  		widget.value = ""
	  	when 'save'
		  	requestMethod = 'POST'
		  	widget = baseWidgetControlSave( widget )
	  url = "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
  	ajaxRequest( requestMethod, url, widget );

triggerClickEventInBindedWidgets = (widget)->
	if @bindedWidgets && @bindedWidgets[widget.nodeNumber]
		for bindedWidget in @bindedWidgets[widget.nodeNumber]
	  	do (bindedWidget) ->
			  $( "##{bindedWidget}" ).trigger('click');

baseWidgetControl =( id ) ->
	$( "##{id}" ).click (e) ->
	  $(this).attr('disabled', 'disabled' )
	  widget = {}
	 	widget = getDataset( e.target )
	 	widget = shouldSaveOnly(widget, id)
	  requestMethod = 'GET'
	  switch widget.state
	  	when 'cancel'
	  		baseWidgetControlCancel( widget );
	  		widget.value = "";
	  	when 'edit'
	  		widget.value = "";
	  	when 'save'
		  	requestMethod = 'POST';
		  	widget = baseWidgetControlSave( widget );
			url = "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
			ajaxRequest( requestMethod, url, widget );
   		
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
		when 'plus_minus_box'
			 widget['data'] =  $("##{inputId(widget)}").val()
		when "checkbox_box"
			widget['data'] = getCheckboxSelectedValue();
		when 'wizard_buttons'
			widget['data'] = widget.value
		when 'date_range_box'
			widget['data'] = {}
			widget['data']['startDate'] = $("#start-date").val()
			widget['data']['endDate'] = $("#end-date").val()
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
    $(this).attr('disabled', 'disabled' )
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
		$(this).attr('disabled', 'disabled' )
		widget = getDataset( e.target )
		widget = shouldSaveOnly(widget)
		shouldSendRequest = true
		if widget.state == "save"
		  	requestMethod = 'POST'
		  	widget['data'] = getPlaceid(widget.inputId); 	
		  	if !getPlaceid(widget.inputId)
				  window.alert( "Please choose a location for your activity before saving" );
				  shouldSendRequest = false		
		if shouldSendRequest
			$.ajax
		    type: requestMethod
		    url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
		    data: widget

getPlaceid = (inputId) ->
	@places[inputId].place_id

schedulingWidgetControl = ( id ) ->
	$( "##{id}" ).click (e) ->
		$(this).attr('disabled', 'disabled' )
		widget = getDataset( e.target )
		if widget.state == "save"
			widget = schedulingWidgetSave( widget ) 
			widget = shouldSaveOnly(widget)
		$.ajax
	    type: "POST"
	    url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget

schedulingWidgetSave = ( data ) ->
	switch data.schedulingType
    when "recurringEvent"
      data = saveRecurringEvent( data );
    when "specificDates"
      data = saveSpecificDate( data );
  data['activityLeader'] = getActivityLeader( data );
  data

saveRecurringEvent = (data) ->
  data['selectedTime'] = $('.dateTimePicker').data('date');
  data['selectedDayOfWeek'] = $('#dayOfWeek').val();
  data

saveSpecificDate = (data) ->
  data['selectedDate'] =  new Date( $('.dateTimePicker').data('date') )
  data

getActivityLeader = (data) ->
  activityLeaders = $('#activityLeader').val();

#Utilities###############################################################################################
ajaxRequest = ( requestMethod, url, widget ) ->
	$.ajax
	  type: requestMethod
	  url: url
	  data: widget

shouldSaveOnly = ( widget, controlId ) ->
	if @bindedWidgets && @bindedWidgets[widget.nodeNumber] && (controlId in @bindedWidgets[widget.nodeNumber])
		widget.saveOnly = true
	widget

getDataset = ( el ) ->
	if ( el.className in ["buttonText", "buttonImage"] )
	 id = el.parentElement.id
	else
	 id = el.id
	$("##{id}").data('widgetData')


