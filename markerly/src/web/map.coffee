###
  Use the Map class to hold methods dealing with the Google Map
###
$ = require('jquery')

module.exports = class Map

###
  Load the map and center it to the current location
###
Map.initializeMap = () ->
  $('#map-canvas').css {
    height: '100%'
    margin: '0px'
    padding: '0px'
  }

  navigator.geolocation.getCurrentPosition(
    (position) ->
      window.coords = position.coords
      mapOptions = {
        zoom: 15
        center: new google.maps.LatLng position.coords.latitude, position.coords.longitude
      }
      window.map = new google.maps.Map document.getElementById('map-canvas'), mapOptions
      # Tell the server the map loaded so that it can send back the list of markers
      window.socket.emit 'mapLoaded', position.coords
    (error) ->
      console.warn 'MAP INIT ERROR(' + err.code + '): ' + err.message
  )

###
  Place a marker on the map
  Add a little randomness to its placement, just for fun
###
Map.setMarker = (position, comment) ->
  lat = parseFloat(position.lat)+(Math.random() * (0.00120 - 0.009200) + 0.009200)
  lon = parseFloat(position.lon)+(Math.random() * (0.00120 - 0.009200) + 0.009200)
  return new google.maps.Marker {
    position: new google.maps.LatLng(lat, lon)
    map: window.map
    title: comment
    visible: true
  }

