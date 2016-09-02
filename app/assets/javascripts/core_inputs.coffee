document.addEventListener 'initDateTimePicker',(e) ->
  initDateTimePicker(e.detail.type);

document.addEventListener 'initMultipleSelectBox', (e) ->
	initMultipleSelectBox( e.detail )

document.addEventListener 'initSider', (e) ->
	initSlider(e.detail.sliderData);

document.addEventListener 'initCheckbox', (e) ->
	initCheckbox();

document.addEventListener 'initCKeditor', (e) ->
	initCKeditor( e.detail )

initCKeditor = ( data ) ->
	data.options.extraPlugins = 'confighelper'
	CKEDITOR.replace( data.id, data.options );

initCheckbox = ( data ) ->
	$('input[type="radio"]').on 'change', ->
		uncheckAllRadioButtons();
		$(this)[0].checked = true;
  	
uncheckAllRadioButtons = ->
	buttons = $('input[type="radio"]')
	for button in buttons
  	button.checked = false

initSlider = ( data ) ->
	$("##{data.id}.sliderInput").slider( { tooltip: 'always', 'min': 0, 'max': data.maxValue, 'steps': parseInt(data.sliderSteps), value: data.value  } )

initMultipleSelectBox = (data) ->
	$("##{data.id}.select2").select2({ theme: "bootstrap",  'maximumSelectionLength': parseInt( data.maxSelections )  });


initDateTimePicker = ( type ) ->
	options = { 
							sideBySide: true
							viewMode: 'days'
							minDate: new Date()
							stepping: 15
							icons:{ time: "fa fa-clock-o", up: "fa fa-arrow-up", down: "fa fa-arrow-down", previous: 'fa fa-arrow-left', next: 'fa fa-arrow-right' }
						};
	if type == 'time'
		options['format'] = 'LT'
		options['defaultDate'] =  moment().add('days', 10)
	$('.dateTimePicker').datetimepicker( options );

