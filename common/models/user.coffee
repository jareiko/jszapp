Model = require './model'
util = require '../util'

module.exports = class User extends Model
  attributeNames: [
    'control'
    'jumping'
    'name'
    'points'
    'pos'
    'screenChange'
    'vel'
  ]
  defaults:
    control: 0
    name: ""
    jumping: 0
    screenChange: 0
    points: 0

  initialize: ->
    super
    # We set these instead of using defaults to avoid object aliasing.
    @set
      pos: [0,0,0]
      vel: [0,0]

    # Non-attributes.
    @scored = {}

  validate: (attributes, options) ->
    "Name too long" if attributes.name.length > 15

  CONTROL:
    LEFT: 1
    RIGHT: 2
    JUMP: 4

  controlLeft:  -> if @control & @CONTROL.LEFT  then 1 else 0
  controlRight: -> if @control & @CONTROL.RIGHT then 1 else 0
  controlJump:  -> if @control & @CONTROL.JUMP  then 1 else 0

  addScore: (key, game) ->
    return if @scored[key]
    @scored[key] = yes
    @points++
    game.trigger 'playsound', 'collect', 0.6, 1

  smallStep: (game, deltaTime) ->
    moveX = (@controlRight() - @controlLeft()) * 5
    moveY = -20
    jump = @controlJump()
    vel = @vel
    pos = @pos

    # pos[0] += Math.random() * 0.1 - 0.05
    # pos[1] += Math.random() * 0.1 - 0.05

    epsilonX = 0.3
    epsilonYup = 0.5
    epsilonYdown = 0.2

    tilesToCheck = (x, epsilonPlus, epsilonMinus) ->
      r = [ Math.floor x ]
      r.push r[0] - 1 if x < r[0] + epsilonPlus
      r.push r[0] + 1 if x > r[0] + 1 - epsilonMinus
      r
    # Solid: 1: left, 2: right, 4: top, 8: bottom
    isSolid = (mask) -> (tile) -> tile.solid & mask
    someElement = (arr, fn) ->
      for el in arr
        return el if fn el
      undefined

    # Vertical movement.
    gravity = if jump and vel[1] > 0 then 1 else 3
    vel[1] = moveY + (vel[1] - moveY) / (1 + deltaTime * gravity)
    targetY = pos[1] + vel[1] * deltaTime

    onGround = no
    ttc = tilesToCheck pos[0], epsilonX, epsilonX
    posYi = Math.floor pos[1]
    targetYi = Math.floor targetY - epsilonYdown
    while posYi > targetYi
      next = (game.getTile posXi, posYi - 1 for posXi in ttc)
      if tile = someElement next, isSolid 0x4
        targetY = posYi + epsilonYdown
        if vel[1] < 0
          onGround = yes
          tile.trigger? 'hit', @, -vel[1]
          vel[1] = 0
          @jumping = 0 unless jump
          unless @jumping
            if jump
              vel[1] = 12
              game.trigger 'playsound', 'jump', 0.4, 0.9 + Math.random() * 0.2
            onGround = yes
        break
      posYi--
    @jumping = 1 if jump
    targetYi = Math.floor targetY + epsilonYup
    while posYi < targetYi
      next = (game.getTile posXi, posYi + 1 for posXi in ttc)
      if tile = someElement next, isSolid 0x8
        targetY = posYi + 1 - epsilonYup
        if vel[1] > 0
          tile.trigger? 'hit', @, vel[1]
          vel[1] = 0
        break
      posYi++
    pos[1] = targetY

    # Horizontal movement.
    friction = if onGround then 15 else 5
    vel[0] = moveX + (vel[0] - moveX) / (1 + deltaTime * friction)
    targetX = pos[0] + vel[0] * deltaTime

    posXi = Math.floor pos[0]
    ttc = tilesToCheck pos[1], epsilonYdown, epsilonYup
    targetXi = Math.floor targetX - epsilonX
    while posXi > targetXi
      next = (game.getTile posXi - 1, posYi for posYi in ttc)
      if tile = someElement next, isSolid 0x2
        targetX = posXi + epsilonX
        if vel[0] < 0
          tile.trigger? 'hit', @, -vel[0]
          vel[0] = 0
        break
      posXi--
    targetXi = Math.floor targetX + epsilonX
    while posXi < targetXi
      next = (game.getTile posXi + 1, posYi for posYi in ttc)
      if tile = someElement next, isSolid 0x1
        targetX = posXi + 1 - epsilonX
        if vel[0] > 0
          tile.trigger? 'hit', @, vel[0]
          vel[0] = 0
        break
      posXi++
    pos[0] = targetX

    posXi = Math.floor pos[0]
    posYi = Math.floor pos[1]
    tile = game.getTile posXi, posYi
    if tile.name is 'easteregg'
      @addScore "egg:#{posXi},#{posYi}", game

    # Determine screen change intent for this user.
    screenDef = game.screens[game.screen]
    min = screenDef.offset
    max = screenDef.offset + screenDef.width
    if pos[0] < min
      vel[0] = util.PULLTOWARD vel[0], 20, 2 * (min - pos[0]) * deltaTime
      @screenChange = -1
    else if pos[0] > max
      vel[0] = util.PULLTOWARD vel[0], -20, 2 * (pos[0] - max) * deltaTime
      @screenChange = 1
    else
      @screenChange = 0
    return
