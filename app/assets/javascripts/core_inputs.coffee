document.addEventListener 'initDateTimePicker',(e) ->
  initDateTimePicker(e.detail.type);

document.addEventListener 'initDateRangePicker',(e) ->
  initDateRangePicker(e.detail.type);

document.addEventListener 'initMultipleSelectBox', (e) ->
	initMultipleSelectBox( e.detail )

document.addEventListener 'initSider', (e) ->
	initSlider(e.detail.sliderData);

document.addEventListener 'initCheckbox', (e) ->
	initCheckbox();

document.addEventListener 'initCKeditor', (e) ->
	initCKeditor( e.detail );

document.addEventListener 'initPlusMinus', (e) ->
	initPlusMinus(e.detail);

document.addEventListener 'initTagSelector', (e) ->
	debugger
	initTagSelector(e.detail.inputId);

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

initPlusMinus = (data) ->
	$("##{data.buttonId}").click (e) ->
		if e.target.tagName == "I"
			data = e.target.parentElement.dataset
		else	
			data = e.target.dataset
		input = $("##{data.inputId}")
		val = parseInt(input.val()) || 0
		if data.behavior == "plus"
			input.val( val + 1 )
		if data.behavior == "minus"
			input.val( val - 1 ) unless val == 0
		
initTagSelector = (inputId) -> 
	$("[data-input-id='#{inputId}']").click (e) ->
		if e.target.dataset.selected == "true"
			e.target.dataset.selected = false
			$(this).removeClass("selectedTag")
		else
			e.target.dataset.selected = true
			$(this).addClass("selectedTag")

initDateRangePicker = () ->
	options = {	'autoApply': true, 'minDate': new Date() 	};
	$('.dateRange').daterangepicker( options );
	
	$('.dateRange').on 'apply.daterangepicker', (ev, picker) ->
	  startDate = dateFormat(picker.startDate.toArray())
	  endDate = dateFormat(picker.endDate.toArray())
	  $('#start-date').val(startDate)
	  $('#end-date').val(endDate)
	  $('#date-range').val("#{startDate} - #{endDate} ")
	
dateFormat = (dateArray) ->
	day = addZeroIfNeeded( dateArray[2] )
	month =   addZeroIfNeeded( (dateArray[1] + 1) )
	year = dateArray[0]
	"#{year}-#{month}-#{day}"

addZeroIfNeeded = ( number ) ->
	if number < 10
		"0#{number}"
	else
		"#{number}"

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

