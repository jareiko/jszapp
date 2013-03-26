express     = require('express')
app         = express()
port        = process.env.PORT or 3000
sio         = require('socket.io')
api         = require('./api')
_           = require('underscore')


module.exports.startServer = ->
  server      = app.listen port
  io          = sio.listen server

  app.use express.logger()
  app.use express.bodyParser()
  app.use '/control', express.static __dirname + "/../control/public"
  app.use '/display', express.static __dirname + "/../display/public"
  app.use '/', express.static(__dirname + "/public")

  api app

  io.set 'transports', ['websocket', 'xhr-polling']
  io.set 'log level', 1
  io.set 'heartbeat timeout', 30
  io.set 'heartbeat interval', 10
  io.enable 'browser client minification'
  io.enable 'browser client etag'
  io.enable 'browser client zip'

  getIsodate = -> new Date().toISOString()

  User = require '../common/models/user'
  Users = require '../common/models/users'
  Game = require '../common/models/game'

  mediator = new (require('events').EventEmitter)()

  game = new Game
  bringGameUpToDate = do ->
    lastTime = Date.now()
    ->
      now = Date.now()
      game.simulate (now - lastTime) * 0.001
      lastTime = now
      mediator.emit 'change'

  # Don't let the game get too far behind.
  setInterval bringGameUpToDate, 1000

  createId = do ->
    nextId = 0
    -> ++nextId

  updateUser = (user, attrs) ->
    user.set (_.pick attrs, 'name', 'control'), validate: yes
    mediator.emit 'change'
    user

  game.on 'change', ->
    mediator.emit 'change'

  socketSync = (socket) ->
    (data, callback) ->
      # callback = (data) ->
      #   _.delay ->
      #     origCallback data
      #   , 200
      bringGameUpToDate()
      error = (msg) -> console.error msg; callback error: msg
      switch data.method
        when 'create'
          switch data.type
            when 'User'
              user = new User id: createId()
              socket.my.user = user
              game.addUser user
              updateUser user, data.attrs
              callback model: user.toJSON()
            else error "Type #{data.type} not implemented for method #{data.method}"
        when 'read'
          switch data.type
            when 'Game'
              callback model: game.toJSON()
            else error "Type #{data.type} not implemented for method #{data.method}"
        when 'update', 'patch'
          switch data.type
            when 'User'
              user = game.users.get data.attrs.id
              userMissing = not user?
              if userMissing
                if socket.my.user?
                  user = socket.my.user
                else
                  user = new User id: createId()
                  game.addUser user
              socket.my.user = user
              updateUser user, data.attrs
              # callback model: (if userMissing then user.toJSON() else {})
              userJson = user.toJSON()
              callback model:
                id: userJson.id
                points: userJson.points
            when 'Game'
              return error "Wrong game id" unless data.attrs.id is game.id
              game.set (_.pick data.attrs, 'screen', 'screenTimer'), validate: yes
              callback {}
            else error "Type #{data.type} not implemented for method #{data.method}"
        else error "Type #{data.type} not implemented for method #{data.method}"
      return

  io.of('/control').on 'connection', (socket) ->
    socket.my = {}
    console.log "[#{getIsodate()}] #{socket.id} CONNECTED as control"
    socket.on 'sync', socketSync socket

    socket.on 'disconnect', ->
      console.log "[#{getIsodate()}] #{socket.id} DISCONNECTED"
      user = socket.my.user
      if user
        game.users.remove user
        mediator.emit 'change'

  io.of('/display').on 'connection', (socket) ->
    socket.my = {}
    console.log "[#{getIsodate()}] #{socket.id} CONNECTED as display"
    socket.on 'sync', socketSync socket

    sendState = _.debounce ->
        socket.emit 'game', { game }
      , 0

    sendState()
    mediator.on 'change', sendState

    socket.on 'disconnect', ->
      console.log "[#{getIsodate()}] #{socket.id} DISCONNECTED"
      mediator.removeListener 'change', sendState

if require.main is module
  module.exports.startServer()
