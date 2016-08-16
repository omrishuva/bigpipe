document.addEventListener 'enableSelectSchedulingTypeButtons', (e) ->
  enableSelectSchedulingTypeButtons();

document.addEventListener 'enableEditSchedulingButtons', (e) ->
  onCancelScheduling();
  onSaveScheduling();

onSaveScheduling = ->
  $("#saveScheduling").click (e) ->
    data = e.target.dataset
    switch data.schedulingType
      when "recuringEvent"
        data = saveRecuringEvent( data );
      when "specificDate"
        data = saveSpecificDate( data );
    data['activityLeader'] = getActivityLeader( data );    
    $.ajax
      type: 'GET'
      url: "/activities/scheduling/save/#{data.activityId}"
      data: data


saveRecuringEvent = (data) ->
  data['selectedTime'] = $('.dateTimePicker').data('date');
  data['selectedDayOfWeek'] = $('#dayOfWeek').val();
  data

saveSpecificDate = (data) ->
  data['selectedDate'] = $('.dateTimePicker').data('date');
  data  

getActivityLeader = (data) ->
  activityLeaders = $('#activityLeader').val();

onCancelScheduling = ->
  $('#cancelScheduling').click (e) ->
    data = e.target.dataset;
    $.ajax
      type: 'GET'
      url: "/activities/scheduling/cancel/#{data.activityId}"

enableCancelScheduling = ->
  $('#cancelScheduling').click (e) ->
    data = e.target.dataset
    $.ajax
      type: 'GET'
      url: "/activities/scheduling/cancel/#{data.activityId}"
      data: data

enableSelectSchedulingTypeButtons = ->
  $('.selectSchedulingTypeButton').click (e) ->
    data = e.target.dataset
    $.ajax
      type: 'GET'
      url: "/activities/select_scheduling_type/#{data.activityId}"
      data: { scheduling_type: data['schedulingType'] }