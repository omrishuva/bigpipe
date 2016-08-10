document.addEventListener 'loadNavigationTabs',(e) ->
  changeUserNavTab();

changeUserNavTab =( ) ->
  $('.userNavtabLink').click (e) ->
    $("a.userNavtabLink.active").removeClass('active');
    $("a.userNavtabLink[name='#{e.target.name}']").addClass('active');
    data = e.target.dataset
    $.ajax
      type: 'GET'
      url: "/profile/navigation/#{e.target.name}"
      data: data
      success: (data) ->
        upgradeToBusiness();
        loadStaffTable();
        document.publishEvent('loadWidgetListeners' );

loadStaffTable = ->
  $('#staffTable').bootstrapTable()

upgradeToBusiness = ->
  $('#upgradeToBusiness').click (e) ->
    $.ajax
      type: 'POST'
      url: "/accounts/upgrade_business/#{e.target.dataset.accountId}"
      success: (data) ->
        document.publishEvent('loadWidgetListeners' );