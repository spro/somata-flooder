zmq = require 'zmq'
async = require 'async'
util = require 'util'
log = (require 'somata').helpers.log

class Client

    connect: (@address) ->
        @socket = zmq.socket 'dealer'
        @socket.identity = 'test'
        @socket.connect @address
        @socket.on 'message', (message_json) =>
            @handleMessage JSON.parse message_json
        log.i 'Connected to ' + @address
        @i = 0

    send: (message, cb) ->
        @socket.send JSON.stringify message
        cb null, true

    handleMessage: (message) ->
        ++@i
        log.d @i if @i%100==0

MSG = ('x' for i in [0..10000]).join('')
c = new Client
c.connect 'tcp://192.168.42.115:5559'
testSending = ->
    async.mapLimit [1..1000], 1000, (n, _cb) ->
        c.send {hi: MSG}, ->
            _cb null, true
setTimeout testSending, 500

