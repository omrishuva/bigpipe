document.addEventListener 'initMap',(e) ->
  initMap( e.detail );

initMap = ( placeId ) ->
  @map = new (google.maps.Map)( document.getElementById( 'map' ), maxZoom: 20, scaleControl: false, scrollwheel: false )
  @placesService = new (google.maps.places.PlacesService)( @map )
  if placeId
    findPlaceById( placeId.place_id )
  else
    setCurrentUserLocation();
   
setCurrentUserLocation = ->
  @currentPlace = null
  if navigator.geolocation && not(window.location.protocol == "http:") 
    navigator.geolocation.getCurrentPosition (position) ->
      radarSearch( { lat: position.coords.latitude, lng: position.coords.longitude } )
  else
    radarSearch( { lat: 32.0864361, lng: 34.7863192 } )

radarSearch = ( coords ) ->
  @placesService.nearbySearch( { location: coords, radius: 1 }, placeServiceCallback )

findPlaceById = ( placeId ) ->
  request = placeId: placeId
  @placesService.getDetails request, placeServiceCallback

placeServiceCallback = (place, status) ->
  if status == google.maps.places.PlacesServiceStatus.OK
    place = place[0] if place instanceof Array
    setMapBounds( place );
    setMarker( place );

setAutocompleteListener = ( marker, infowindow ) ->
  input = document.getElementById('pac-input')
  if input
    autocomplete = new (google.maps.places.Autocomplete)(input)
    autocomplete.bindTo 'bounds', @map
    autocomplete.addListener 'place_changed', =>
      infowindow.close()
      marker.setVisible false
      @currentPlace = autocomplete.getPlace()
      setMapBounds( @currentPlace );
      setMarker( @currentPlace );
      
setMapBounds = ( place ) ->
  if !place.geometry
    window.alert 'Autocomplete\'s returned place contains no geometry'
    return
  if place.geometry.viewport
    @map.fitBounds place.geometry.viewport
  else
    @map.setCenter place.geometry.location
    @map.setZoom 17

setInfoWindowContent = ( place, marker ) ->
  infowindow = new (google.maps.InfoWindow)
  address = buildAddressName( place );
  if address
    infowindow.setContent '<div><strong>' + place.name + '</strong><br>' + address
  else
    infowindow.setContent '<div><strong>' + place.name
  infowindow.open @map, marker
  return infowindow

setMarker =  ( place ) ->
  marker = new (google.maps.Marker)(
    map: map
    anchorPoint: new (google.maps.Point)(0, -29))
  marker.setIcon
      url: "https://res.cloudinary.com/kommunal/image/upload/v1470046197/Map_Pin-100_ysareo.png"
      size: new (google.maps.Size)(71, 71)
      origin: new (google.maps.Point)(0, 0)
      anchor: new (google.maps.Point)(17, 34)
      scaledSize: new (google.maps.Size)(35, 35)
  marker.setPosition place.geometry.location
  marker.setVisible true
  infowindow = setInfoWindowContent( place, marker );
  setAutocompleteListener( marker, infowindow )
  
  marker.addListener 'click', ->
    infowindow.open @map, marker

buildAddressName = ( place ) ->
  address = '' 
  if place.address_components
    address = [
        place.address_components[0] and place.address_components[0].short_name or ''
        place.address_components[1] and place.address_components[1].short_name or ''
        place.address_components[2] and place.address_components[2].short_name or ''
      ].join(' ')