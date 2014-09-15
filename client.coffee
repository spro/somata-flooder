somata = require 'somata/src'
util = require 'util'
async = require 'async'

log = somata.helpers.log

c = new somata.Client

send = (s, cb) ->
    c.remote 'flooder', 'echo', s, (err, response) ->
        if response == 'ok ' + s
            cb null, response
        else
            cb 'bad response: ' + response

t = 0 # Total successful responses
N = parseInt process.argv[2] # Number of messages to send
S = 2 ** 15 # 20 1MB message string
s = ('x' for i in [0..S-1]).join('')

log.i "Sending #{ N } pings..."

flood = ->
    async.mapLimit [1..N], 10, (i, _cb) ->
        send s+i, (err, response) ->
            if err
                log.e err
                _cb err
            else
                t++
                log.d [i, t].join ', '
                _cb null, true

    , (err, successes) ->
        if successes.length == N
            log.s "Success"
        else
            log.w "Only got #{ successes.length }"
        process.exit()

showConnections = ->
    log.i util.inspect c.service_connections.flooder.socket

# Try warming up
#c.remote 'flooder', 'hello'
setTimeout flood, 500
setTimeout showConnections, 5000

