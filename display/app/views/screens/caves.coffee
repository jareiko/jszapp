Screen = require './screen'

module.exports = class Caves extends Screen
  constructor: (@screen, @engine) ->
    super
    engine.addText @, 0.8, 0x009000, 10, 2.1, "60 FPS zone"
    engine.addText @, 0.8, 0x009000, 26, 2.1, "30 FPS zone"
    engine.addText @, 0.8, 0x009000, 42, 2.1, "15 FPS zone"

  update: (deltaTime) ->
    avg = @engine.game.avg
    offset = @screen.offset

    busyDelay = (ms) ->
      stop = Date.now() + ms
      twiddleThumbs = ->
      twiddleThumbs() while Date.now() < stop
      return

    if avg < offset + 49
      if avg >= offset + 34
        busyDelay 55
      else if avg >= offset + 18
        busyDelay 25
    return
