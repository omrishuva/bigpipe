$(document).ready ->
	textWidgetControl("textAreaBox");
	textWidgetControl("textInputBox");
	imageWidgetControl();

document.addEventListener 'loadWidgetListeners',(e) ->
  textWidgetControl("textAreaBox");
  textWidgetControl("textInputBox");
  imageWidgetControl();

textWidgetControl =( widgetName ) ->
	$("[data-element-name='#{widgetName}'].widgetControl").click (e) ->
	  widget = {}
	  widget = e.target.dataset
	  cancel( widget ) if widget.state == 'cancel'	  
	  widget['data'] = save( widget ) if widget.state == 'save'
	  $.ajax
	    type: 'GET'
	    url: "/widgets/text_widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget
   		success: (data) ->
      	textWidgetControl( widgetName );

save = ( widget ) ->
	location.search = ""
	if widget.widgetName == "text_area_box"
		CKEDITOR.instances.editor1.getData()
	else
		$("input[name='#{widget.widgetName}']").val()


cancel = ( widget ) ->
	location.search = ""
	if widget.widgetName == "text_area_box"
		CKEDITOR.instances.editor1.destroy()
		$( ".textAreaBox" ).hide();

imageWidgetControl = ->
  $('.imageUploadInput').change (e) ->
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
          onImageUpload();
