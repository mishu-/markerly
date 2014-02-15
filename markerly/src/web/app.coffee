$ = require('jquery')
Map = require('./map.coffee')

# Make our life easy and have this available everywhere
window.socket = io.connect "http://localhost:5445"

socket.on 'initialize', (data)->
  $('#server_status').html "Elasticsearch service status is " + data.message.status

###
  Load nearby markers
###
socket.on 'loadMarkers', (data) ->
  for marker in data
    Map.setMarker marker._source.location, marker._source.comment

###
  Receive a new marker
###
socket.on 'newMarker', (data) ->
  Map.setMarker data.location, data.comment


###
  Send new marker to server
  Load the coords again, maybe we moved since the page was first loaded
###
$('#send_comment').on 'click', (event) =>
  event.preventDefault()
  navigator.geolocation.getCurrentPosition(
    (position) ->
      socket.emit 'saveMarker', {
        comment: $('#comment-form #comment')[0].value
        location:
          lat: position.coords.latitude
          lon: position.coords.longitude
      }
    (error) ->
      console.warn 'ERROR(' + err.code + '): ' + err.message
  )

google.maps.event.addDomListener window, 'load', Map.initializeMap
