module.exports = ->
  _.extend @, Backbone.Events

  getGamepads = ->
    n = navigator
    n.getGamepads?() or n.gamepads or
    n.mozGetGamepads?() or n.mozGamepads or
    n.webkitGetGamepads?() or n.webkitGamepads or
    []

  gamepadMap = {}

  @update = =>
    for gamepad, i in getGamepads()
      continue unless gamepad?
      unless map = gamepadMap[i]
        map = gamepadMap[i] =
          gp: gamepad
          pa: {}  # previous axis values
          pb: {}  # previous button values
        _.extend map, Backbone.Events
        @trigger 'gamepadconnected', map
      for value, i in gamepad.axes
        map.trigger 'axischange', i, value, map.pa[i] if value isnt map.pa[i]
        map.pa[i] = value
      for value, i in gamepad.buttons
        map.trigger 'buttonchange', i, value, map.pb[i] if value isnt map.pb[i]
        map.pb[i] = value
  return
