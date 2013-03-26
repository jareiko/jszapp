# The application bootstrapper.
Application =
  initialize: ->
    Model = require 'common/models/model'
    Router = require 'lib/router'
    PlayView = require 'views/play'
    SetupView = require 'views/setup'
    User = require 'common/models/user'
    iosync = require 'common/iosync'

    socket = io.connect '/control',
      'max reconnection attempts': 50
    Model::sync = iosync.syncSocket socket

    for evt in ['connect', 'connecting', 'disconnect', 'connect_failed', 'error', 'reconnect_failed', 'reconnect', 'reconnecting']
      do (evt) -> socket.on evt, -> console.log "socket.io: #{evt}"

    @user = new User()
    saveUser = => @user.save null

    @user.on 'change', saveUser
    socket.on 'connect', saveUser
    #socket.on 'reconnect', saveUser

    @playView = new PlayView()
    @setupView = new SetupView()

    # Instantiate the router
    @router = new Router()
    # Freeze the object
    Object.freeze? this

  showPlay: ->
    $('body').append @playView.render().el

module.exports = Application
