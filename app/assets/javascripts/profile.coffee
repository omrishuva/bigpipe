document.addEventListener 'loadNavigationTabs',(e) ->
  changeUserNavTab();

document.addEventListener 'loadBootstrapTable', (e) ->
  loadStaffTable( e.detail )

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
        document.publishEvent('loadWidgetListeners' );

loadStaffTable = ( options ) ->
  jQuery.fn.bootstrapTable.columnDefaults.sortable = true
  if options.locale == 'he'
    jQuery.fn.bootstrapTable.columnDefaults.align = 'right'
    jQuery.fn.bootstrapTable.columnDefaults.halign = 'right'
    tableOptions = { locale:'he' }
  else
    tableOptions = { }
  $('#staffTable').bootstrapTable( tableOptions );
  $('#staffTable').bootstrapTable('hideLoading');

upgradeToBusiness = ->
  $('#upgradeToBusiness').click (e) ->
    $.ajax
      type: 'POST'
      url: "/accounts/upgrade_business/#{e.target.dataset.accountId}"
      data: e.target.dataset.accountId
      success: (data) ->
        document.publishEvent('loadWidgetListeners');