$(document).ready ->
  changeUserNavTab();

changeUserNavTab =( exclude ) ->
  $('.userNavtabLink').click (e) ->
    $("a.userNavtabLink.active").removeClass('active');
    $("a.userNavtabLink[name='#{e.target.name}']").addClass('active');
    data = e.target.dataset
    $.ajax
      type: 'GET'
      url: "/profile/navigation/#{e.target.name}"
      data: data
      success: (data) ->
        document.publishEvent('loadWidgetListeners' );