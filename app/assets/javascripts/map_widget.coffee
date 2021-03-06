document.addEventListener 'initMap',(e) ->
  initMap( e.detail )

initMap = ( data ) ->
  @map = new (google.maps.Map)( document.getElementById( "map" ), maxZoom: 20, scaleControl: false, scrollwheel: false )
  @markers = {}
  @places = {}
  initPlacesService();
  setPlacesOnMap( );

initPlacesService = ->
  @placesService = new (google.maps.places.PlacesService)( @map )

setPlacesOnMap = () ->
  inputs = getMapInputs()
  if inputs
    for input in inputs
      setPlaceFromPlaceIdSearch( input.dataset.placeId )
  
setPlaceFromPlaceIdSearch = ( placeId ) ->
  request = placeId: placeId
  @placesService.getDetails request, placeServiceCallback

placeServiceCallback = (place, status) ->
  if status == google.maps.places.PlacesServiceStatus.OK
    place = place[0] if place instanceof Array
    setMarker( place );

setCurrentUserLocation = ->
  @currentPlace = null
  if navigator.geolocation && not(window.location.protocol == "http:") 
    navigator.geolocation.getCurrentPosition (position) ->
      radarSearch( { lat: position.coords.latitude, lng: position.coords.longitude } )
  else
    radarSearch( defaultCoordinates(); )

setAutocompleteListener = ( marker, infowindow, input ) ->
  autocomplete = new (google.maps.places.Autocomplete)(input, { 'types': [input.dataset.type] })
  autocomplete.bindTo 'bounds', @map
  autocomplete.addListener 'place_changed', =>
    place = autocomplete.getPlace()
    @places[input.id] = place
    input.dataset.placeId = place.place_id
    if input.dataset.submitOnChnage == "true"
      document.publishEvent("submitInputOnChange", { 'input': input } )
    if marker
      markers[input.id].setVisible false
      setMarker( place );
    infowindow.close() if infowindow

getMapInputs = -> 
  $(".pac-input")

radarSearch = ( coords ) ->
  @placesService.nearbySearch( { location: coords, radius: 1 }, placeServiceCallback )

setMapBounds = ->
  bounds = new google.maps.LatLngBounds();
  for inputId, place of @places
    lat = place.geometry.location.lat()
    lng = place.geometry.location.lng()
    myLatLng = new google.maps.LatLng(lat, lng);
    bounds.extend(myLatLng);
    @map.fitBounds(bounds);


focusOnPlace = ( place ) ->
  if !place.geometry
    window.alert 'Autocomplete\'s returned place contains no geometry'
    return
  if place.geometry.viewport
    @map.fitBounds place.geometry.viewport
  else
    @map.setCenter place.geometry.location
    @map.setZoom 17

setInfoWindowContent = ( place, marker, input ) ->
  infowindow = new (google.maps.InfoWindow)
  address = buildAddressName( place );
  if address
    infowindow.setContent "</br><div><strong>#{input.dataset.key}</strong></br>#{place.name}<br>#{address}"
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
  matchingInput = findMatchingInputToMarker( place.place_id )
  infowindow = setInfoWindowContent( place, marker, matchingInput );
  setAutocompleteListener( marker, infowindow, matchingInput )
  @markers["#{matchingInput.id}"] = marker
  @places["#{matchingInput.id}"] = place
  setMapBounds()
  marker.addListener 'click', ->
    infowindow.open @map, marker
  

findMatchingInputToMarker = (placeId) ->
  $(".pac-input[data-place-id=#{placeId}]")[0]

buildAddressName = ( place ) ->
  address = '' 
  if place.address_components
    address = [
        place.address_components[0] and place.address_components[0].short_name or ''
        place.address_components[1] and place.address_components[1].short_name or ''
        place.address_components[2] and place.address_components[2].short_name or ''
      ].join(' ')
defaultCoordinates = ->
  { lat: 32.0864361, lng: 34.7863192 }