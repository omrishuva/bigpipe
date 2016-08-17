document.addEventListener 'initDateTimePicker',(e) ->
  initDateTimePicker(e.detail.type);

document.addEventListener 'initMultipleSelectBox', (e) ->
	initMultipleSelectBox( e.detail )

document.addEventListener 'initSider', (e) ->  	
	initSlider();

initSlider = ->
	$('.sliderInput').slider( { tooltip: 'always' } )

initMultipleSelectBox = (data) ->
	$(".select2").select2({ theme: "bootstrap",  'maximumSelectionLength': parseInt(data['maxSelections']), 'closeOnSelect': false  });


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
		options['defaultDate'] =  moment().add('days', 2)
	$('.dateTimePicker').datetimepicker( options );		