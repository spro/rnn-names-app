polar = require 'polar'
somata = require 'somata'
config = require './config'
announce_middleware = require('nexus-announce/lib/middleware')(config.announce)
client = new somata.Client

app = polar config.app, middleware: [announce_middleware]

app.get '/', (req, res) ->
    res.render 'index'

prepare = (s) ->
    s = s.trim().replace(/[^a-zA-Z ]/, '')
    if s.length == 0
        s = 'A'
    s = s[0].toUpperCase() + s.slice(1)
    return s

app.get '/generate.json', (req, res) ->
    q = prepare req.query.q or ''
    if q.length > 20
        res.send 500, "Input is too long"
    else
        client.remote 'rnn-names-generator', 'generate', q, (err, got) ->
            if err
                console.log "Error:", err
                res.send 500, err
            else
                res.json got

app.start()
