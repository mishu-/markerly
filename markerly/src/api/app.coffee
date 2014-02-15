connect = require 'connect'
io = require 'socket.io'
elasticsearch = require 'elasticsearch'

###
  Socket server & clients setup
###
server = connect.createServer(connect.static(__dirname+'/../public')).listen(5445)
socket = io.listen(server)
es = new elasticsearch.Client {
                host: 'localhost:9200'
                apiVersion: '1.0'
            }

# Keep a global lock to prevent any requests while elasticsearch is setting up
elasticsearch_ready = false

# This is where we will store the markers data
index_name = 'markers'

# Elasticsearch index 'schema'
# We need this because the geo_point field type is not sauto-discoverable
mapping = {
  _source:
    enabled: true
  properties:
    comment:
      type: 'string'
    location:
      type: "geo_point"
  _timestamp:
      enabled: true
}

# Ensure the index is present, if not, create a new one
es.indices.exists({index:'markers'}).then(
    (success) ->
      if not success
        console.log 'Index missing creating a new one'
        es.indices.create(
          index: index_name
        ).then(
          (success) ->
            es.indices.putMapping
              index: index_name
              type: 'marker'
              body:
                marker: mapping
            elasticsearch_ready = true
            console.log 'Created index and mapping'
        )
      else
        console.log "Found '#{ index_name }' index!"
        elasticsearch_ready = true
    (error) ->
      console.log 'Something went wrong:'
      console.log error
)

socket.on 'connection' , (client) ->

  ###
    When the user sends in a new marker, save it to elasticsearch
  ###
  client.on 'saveMarker' , (data) ->
    unless not elasticsearch_ready
      es.index(
        index: index_name
        type: 'marker'
        body: data
      ).then(
        (success) ->
          console.log "success #{ JSON.stringify(success) }"
          client.emit 'newMarker', data
        (error) ->
          console.error "error #{ JSON.stringify(error) }"
      )
    else
      console.log "Index '#{ index_name }' not ready"

  ###
    Query ES for nearby markers after the client initializes its map
  ###
  client.on 'mapLoaded' , (data) ->
    if not data?
      return
    console.log "Map loaded, send back nearby markers to " +
                "#{ JSON.stringify(data.latitude) }, "+
                "#{ JSON.stringify(data.longitude) }"
    es.search(
      index: 'markers'
      type: 'marker'
      body:
        query:
          match_all: {}
        filter:
          geo_distance:
            distance: "500m"
            location:
              lat: data.latitude
              lon: data.longitude
    ).then(
      (response) ->
        client.emit 'loadMarkers', response.hits.hits
      (err) ->
        console.trace err.message
    )

  ###
    Send elasticsearch cluster color to the client (because we can)
  ###
  es.cluster.health (err, resp) ->
    if (err)
      client.emit 'initialize',
        message: err.message
    else
      client.emit 'initialize',
        message: resp
