document.addEventListener 'initMap',(e) ->
  initMap();

initMap = ->
  @map = new (google.maps.Map)(document.getElementById('map'),
    center:
      lat: -33.8688
      lng: 151.2195
    zoom: 13)

  @input = document.getElementById('pac-input')
  @types = document.getElementById('type-selector')
  initSearchAutocomplete();
  initInfoWindow();
  initMarker();  
  setAutocompleteListener() if @input

initSearchAutocomplete = ->
  @autocomplete = new (google.maps.places.Autocomplete)(@input)
  @autocomplete.bindTo 'bounds', @map

initInfoWindow = ->
  @infowindow = new (google.maps.InfoWindow)

initMarker = ->
  @marker = new (google.maps.Marker)(
    map: @map
    anchorPoint: new (google.maps.Point)(0, -29))

setAutocompleteListener = -> 
  @autocomplete.addListener 'place_changed', =>
    @infowindow.close()
    @marker.setVisible false
    @place = @autocomplete.getPlace()  
    setMapBounds();
    setMarkerIcon();
    buildAddressName();
    setInfoWindowContent();

setMapBounds = ->
  if !@place.geometry
    window.alert 'Autocomplete\'s returned place contains no geometry'
    return
  
  if @place.geometry.viewport
    @map.fitBounds @place.geometry.viewport
  else
    @map.setCenter @place.geometry.location
    @map.setZoom 17

setInfoWindowContent = ->
  @infowindow.setContent '<div><strong>' + @place.name + '</strong><br>' + @address
  @infowindow.open @map, @marker

setMarkerIcon = ->
  @marker.setIcon
      url: @place.icon
      size: new (google.maps.Size)(71, 71)
      origin: new (google.maps.Point)(0, 0)
      anchor: new (google.maps.Point)(17, 34)
      scaledSize: new (google.maps.Size)(35, 35)
  @marker.setPosition @place.geometry.location
  @marker.setVisible true

buildAddressName = ->
  @address = '' 
  if @place.address_components
    @address = [
        place.address_components[0] and place.address_components[0].short_name or ''
        place.address_components[1] and place.address_components[1].short_name or ''
        place.address_components[2] and place.address_components[2].short_name or ''
      ].join(' ')