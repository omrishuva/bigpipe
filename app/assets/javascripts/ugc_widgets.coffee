$(document).ready ->
	loadWidgets();

document.addEventListener 'loadWidgetListeners',(e) ->
  loadWidgets();

loadWidgets = ->
	widgetControls = $('.widgetControl')	 
	for widgetControl in widgetControls
	 	selectorKey = buildWidgetSelectorKey( widgetControl.dataset )
	 	textWidgetControl( selectorKey ) if widgetControl.dataset.widgetName in [ "text_area_box", "text_input_box"]
		imageWidgetControl( selectorKey ) if widgetControl.dataset.widgetName == "image_box"

buildWidgetSelectorKey = ( widgetData) ->
	"##{widgetData.objectId}.widgetControl[data-element-name='#{widgetData.elementName}']"

textWidgetControl =( selectorKey ) ->
	$( selectorKey ).click (e) ->
	  widget = {}
	  widget = e.target.dataset
	  textWidgetControlCancel( widget ) if widget.state == 'cancel'	  
	  widget['data'] = textWidgetControlSave( widget ) if widget.state == 'save'
	  $.ajax
	    type: 'GET'
	    url: "/widgets/text_widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget
   		success: (data) ->
      	textWidgetControl( selectorKey );

textWidgetControlSave = ( widget ) ->
	location.search = ""
	if widget.widgetName == "text_area_box"
		CKEDITOR.instances["editor#{widget.objectId}"].getData()
	else
		$("input[name='#{widget.widgetName}']").val()

textWidgetControlCancel = ( widget ) ->
	location.search = ""
	if widget.widgetName == "text_area_box"
		CKEDITOR.instances["editor#{widget.objectId}"].destroy()
		$( "##{widget.objectId}.textAreaBox" ).hide();

imageWidgetControl = ( selectorKey ) ->
  $( selectorKey ).change (e) ->
    formData = new FormData
    file = e.target.files[0]
    widget = e.target.dataset
    formData.append( 'image', file, file.name )
    formData.append( 'widget', JSON.stringify(widget) )
    $.ajax
        type: 'POST'
        url: "/widgets/image_widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
        data: formData
        processData: false
        contentType: false
        success: (data) ->
          imageWidgetControl( selectorKey );
