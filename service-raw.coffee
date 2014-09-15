zmq = require 'zmq'
util = require 'util'
log = (require 'somata').helpers.log

class Service

    connect: (@address) ->
        @socket = zmq.socket 'router'
        @socket.bindSync @address
        @socket.on 'message', (client_id, message_json) =>
            try
                @handleMessage client_id.toString(), JSON.parse message_json
            catch e
                log.e e
                process.exit()
        @socket.on 'error', (error) ->
            log.e e
        log.i 'Bound to ' + @address
        @i = 0

    sending: ->
        
    send: (client_id, message) ->
        if !client_id
            log.e 'No client id'
            process.exit()
        try
            @socket.send [ client_id, JSON.stringify message ]
        catch e
            log.e e
            process.exit()

    handleMessage: (client_id, message) ->
        #log.s "<#{ client_id }>: " + util.inspect message
        @i++
        log.d @i if @i%100==0
        @send client_id,
            id: message.id
            response: @i

s = new Service
s.connect 'tcp://10.132.236.16:5559'

showResults = ->
    log util.inspect s, {colors: true, depth: null}

process.stdin.on 'data', ->
    showResults()
process.stdin.resume()
