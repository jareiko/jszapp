_           = require 'underscore'
Game        = require '../common/models/game'
Collection  = require '../common/models/collection'
User        = require '../common/models/user'

game = new Game


module.exports = (app) ->
  base = '/v1'

  app.get base + "/info", (req, res) ->
    res.type "application/json"
    res.send JSON.stringify
      api_version: 1

  app.get base + "/users/:user_id", (req, res) ->
    res.type "application/json"

    user = game.users.get req.params['user_id']

    if user?
      res.send JSON.stringify user.filterAuth no
    else
      res.send 404,
        error: "Not found"
