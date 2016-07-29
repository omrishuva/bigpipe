# $(document).ready ->
# 	map();

# document.addEventListener 'drawMap',(e) ->
#   map();

# map = ->
# 	handler = Gmaps.build('Google')
# 	handler.buildMap {
# 	  provider: {  maxZoom: 18 } 
# 	  internal: id: 'map'
# 	}, ->
# 	  markers = handler.addMarkers([ {
# 	    'lat': 48.85837009999999
# 	    'lng': 2.2944813
# 	    'marker': '<i class="fa fa-map-marker" aria-hidden="true"></i>'
# 	    'infowindow': 'Yoga'
# 	  } ])
# 	  handler.bounds.extendWith markers
# 	  handler.fitMapToBounds()
# 	  debugger
# 	  handler.map.centerOn( { lat: 48.85837009999999, lng: 2.2944813 } )

# # 'picture':
# #   'url': 'http://people.mozilla.com/~faaborg/files/shiretoko/firefoxIcon/firefox-32.png'
# #   'width': 32
# #   'height': 32
# #   'infowindow': 'hello!'