somata = require 'somata'
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
S = 2 ** 20 # 1MB message string
s = ('x' for i in [0..S-1]).join('')

log.i "Sending #{ N } pings..."

async.mapLimit [0..N-1], 100, (i, _cb) ->
    send s+i, (err, response) ->
        if err
            console.log err
            _cb err
        else
            t++
            _cb null, true

, (err, successes) ->
    if successes.length == N
        log.s "Success"
    else
        log.w "Only got #{ successes.length }"
    process.exit()

