Screen = require './screen'

module.exports = class Intro extends Screen
  constructor: (screen, engine) ->
    super
    engine.addCenterText @, screen, 1,   0x009000, 10, "HTML5 Game Tech"
    engine.addCenterText @, screen, 0.5, 0x009000, 9, "Jasmine Kent (@jareiko)"
