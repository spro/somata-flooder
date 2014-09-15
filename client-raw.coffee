zmq = require 'zmq'
async = require 'async'
util = require 'util'
log = (require 'somata').helpers.log

randomString = (len) ->
    s = ''
    while s.length < len
        s += Math.random().toString(36).slice(2, len-s.length+2)
    return s

class Client

    connect: (@address) ->
        @socket = zmq.socket 'dealer'
        @socket.identity = 'test'
        @socket.connect @address
        @socket.on 'message', (message_json) =>
            @handleMessage JSON.parse message_json
        @socket.on 'error', (e) ->
            log.e e
        log.i 'Connected to ' + @address

    pending: {}

    send: (message, cb) ->
        message.id ||= randomString 16
        @socket.send JSON.stringify message
        log.w 'Pending exists' if @pending[message.id]?
        @pending[message.id] = cb

    handleMessage: (message) ->
        if cb = @pending[message.id]
            cb null, message.response

n_responses = 0
MSG = ('x' for i in [0..1000]).join('')
c = new Client
c.connect 'tcp://10.132.236.16:5559'
testSending = ->
    async.parallelLimit ([1..1000].map (n) -> (cb) ->
        c.send {hi: MSG}, ->
            ++n_responses
            log.d n_responses if n_responses%100==0
            cb()
    ), 15
setTimeout testSending, 1000

showResults = ->
    log.i n_responses
    log util.inspect c, {colors: true, depth: null}

process.stdin.on 'data', ->
    showResults()
process.stdin.resume()
