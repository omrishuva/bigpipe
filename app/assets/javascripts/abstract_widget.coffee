
$(document).ready ->
	abstractWidgetControl("textAreaBox");
	abstractWidgetControl("textInputBox");


document.addEventListener 'loadWidgetListeners',(e) ->
  abstractWidgetControl("textAreaBox");
  abstractWidgetControl("textInputBox");
  

abstractWidgetControl =( widgetName ) ->
	$("[data-element-name='#{widgetName}'].widgetControl").click (e) ->
	  widget = {}
	  widget = e.target.dataset
	  if widget.state == 'cancel'
	  	if widget.widgetName == "text_area_box"
		    CKEDITOR.instances.editor1.destroy() 
		    $( ".textAreaBox" ).hide();
	    location.search = ""
	  if widget.state == 'save'
	    widget['data'] = CKEDITOR.instances.editor1.getData() if widget.widgetName == "text_area_box";
	    location.search = ""
	  $.ajax
	    type: 'GET'
	    url: "/widgets/widget_control/#{widget.widgetName}/#{widget.objectName}/#{widget.key}"
	    data: widget
   		success: (data) ->
      	abstractWidgetControl( widgetName );
