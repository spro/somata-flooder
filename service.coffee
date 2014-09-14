somata = require 'somata'

echo = (v, cb) -> cb null, 'ok ' + v

s = new somata.Service 'flooder', {
    echo
}

