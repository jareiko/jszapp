# The application bootstrapper.
module.exports = Application =
  initialize: ->
    Game = require 'common/models/game'
    HomeView = require 'views/home_view'
    Model = require 'common/models/model'
    Router = require 'lib/router'
    iosync = require 'common/iosync'

    socket = io.connect '/display'
    Model::sync = iosync.syncSocket socket

    for evt in ['connect', 'connecting', 'disconnect', 'connect_failed', 'error', 'reconnect_failed', 'reconnect', 'reconnecting']
      do (evt) -> socket.on evt, -> console.log "socket.io: #{evt}"

    game = @game = new Game()
    game.fetch()

    socket.on 'game', (data) ->
      game.set game.parse data.game

    @homeView = new HomeView()

    # Instantiate the router
    @router = new Router()
    # Freeze the object
    Object.freeze? this
