Screen = require './screen'

module.exports = class Intro extends Screen
  constructor: (screen, engine) ->
    super
    # engine.addCenterText @, screen, 0.5, 0x009000, 8, "Run rabbits, run!"
