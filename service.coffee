somata = require 'somata/src'
util = require 'util'
log = somata.helpers.log

i = 0
echo = (v, cb) ->
    log.d ++i
    if i%1000==0
        log.i util.inspect s.rpc_binding.socket
    cb null, 'ok ' + v

s = new somata.Service 'flooder', {
    echo
}

