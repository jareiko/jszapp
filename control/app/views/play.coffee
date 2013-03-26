GamepadManager = require 'common/gamepadmanager'
View           = require './view'
app            = require 'application'

module.exports = class PlayView extends View
  id: 'play-view'

  template: require './templates/play'

  afterRender: ->
    @$('button').focus()

    $controlLeft  = @$el.find "#controlLeft"
    $controlRight = @$el.find "#controlRight"
    $controlJump  = @$el.find "#controlJump"

    app.user.on 'change:control', (user, value) =>
      $controlLeft.toggleClass  'highlight', Boolean(value & user.CONTROL.LEFT)
      $controlRight.toggleClass 'highlight', Boolean(value & user.CONTROL.RIGHT)
      $controlJump.toggleClass  'highlight', Boolean(value & user.CONTROL.JUMP)

    evt = (el, name, handler) ->
      el.addEventListener name, handler, no

    evtSave = (el, name, handler) ->
      evt el, name, (event) ->
        return if event.button  # LMB = 0
        return if handler(event) is 'ignore'
        event.preventDefault()
        false

    onStart = ($el, handler) =>
      el = $el[0]
      evtSave el, 'mousedown',   handler
      evtSave el, 'touchstart',  handler

    onStop = ($el, handler) =>
      el = $el[0]
      evtSave el, 'mouseup',     handler
      evtSave el, 'mouseout',    handler
      evtSave el, 'touchend',    handler
      evtSave el, 'touchcancel', handler
      evtSave el, 'touchleave',  handler

    onStart $controlLeft,  -> app.user.control |=  app.user.CONTROL.LEFT
    onStop  $controlLeft,  -> app.user.control &= ~app.user.CONTROL.LEFT
    onStart $controlRight, -> app.user.control |=  app.user.CONTROL.RIGHT
    onStop  $controlRight, -> app.user.control &= ~app.user.CONTROL.RIGHT
    onStart $controlJump,  -> app.user.control |=  app.user.CONTROL.JUMP
    onStop  $controlJump,  -> app.user.control &= ~app.user.CONTROL.JUMP

    KEYCODE =
      BACKSPACE: 8
      TAB: 9
      ENTER: 13
      SHIFT: 16
      CTRL: 17
      ALT: 18
      ESCAPE: 27
      SPACE: 32
      LEFT: 37
      UP: 38
      RIGHT: 39
      DOWN: 40
      DELETE: 46
      COMMA: 188
      PERIOD: 190

    evtSave document, 'keydown', (event) ->
      switch event.keyCode
        when KEYCODE.LEFT  then app.user.control |=  app.user.CONTROL.LEFT
        when KEYCODE.RIGHT then app.user.control |=  app.user.CONTROL.RIGHT
        when KEYCODE.UP    then app.user.control |=  app.user.CONTROL.JUMP
        else 'ignore'

    evtSave document, 'keyup', (event) ->
      switch event.keyCode
        when KEYCODE.LEFT  then app.user.control &= ~app.user.CONTROL.LEFT
        when KEYCODE.RIGHT then app.user.control &= ~app.user.CONTROL.RIGHT
        when KEYCODE.UP    then app.user.control &= ~app.user.CONTROL.JUMP
        else 'ignore'
