Screen = require './screen'

module.exports = class Audio extends Screen
  constructor: (screen, tools) ->
    super
    tools.addCenterText @, screen, 1, 0x009000, 11, "Web Audio API"
