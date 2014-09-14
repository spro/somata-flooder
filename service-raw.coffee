zmq = require 'zmq'
util = require 'util'
log = (require 'somata').helpers.log

class Service

    connect: (@address) ->
        @socket = zmq.socket 'router'
        @socket.bindSync @address
        @socket.on 'message', (client_id, message_json) =>
            @handleMessage client_id.toString(), JSON.parse message_json
        log.i 'Bound to ' + @address
        @i = 0

    send: (client_id, message) ->
        @socket.send [ client_id, JSON.stringify message ]

    handleMessage: (client_id, message) ->
        #log.s "<#{ client_id }>: " + util.inspect message
        ++@i
        log.d @i if @i%100==0
        @send client_id, {got: message}

s = new Service
s.connect 'tcp://192.168.42.115:5559'

