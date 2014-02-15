markerly
========

Google markers map backed by Elasticsearch through Socket.io

### What it does

When the page loads, a google map gets centered to the user's current location.
Nearby markers are displayed. Users can add new markers to the map.

### Under the hood

The aim of this prototype is to showcase ElasticSearch's geo-coordinates based searches.
The web framework support is provided by https://github.com/0x4139/dot
The client server communication is handled by socket.io, while the markers are stored in an ElasticSearch index.

### Install
You need to have Elasticsearch v1.0.0 installed and running on localhost:9200 for the prototype to work.
To install all the other requirements and start server just run:
```
npm install
node_modules/.bin/gulp
```

### How it looks like right now
![Version 0.0.1](/docs/screenshot_0.0.1.png "Version 0.0.1")
