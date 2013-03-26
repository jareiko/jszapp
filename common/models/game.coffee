Model = require './model'
Users = require './users'

deepClone = (obj) -> JSON.parse JSON.stringify obj

module.exports = class Game extends Model
  attributeNames: [
    # 'clock'  # Not an attribute. Not shared.
    'users'
    'screen'
    'screenTimer'
  ]

  defaults:
    id: 1           # THERE CAN BE ONLY ONE.
    screen: 1       # Start on the second screen. The first is a visual buffer.
    screenTimer: -1

  initialize: ->
    super
    @users = new Users

    # Non-attributes.
    @clock = 0
    @tileCache = {}
    @avg = 0        # Mean user hz position.

    # Yikes. @screens belongs to the prototype, but now depends on this instance.
    # Horribly broken alert!
    for s in @screens
      s.initialize? @

  arrayMult = (val, count) ->
    val for i in [0...count]

  hallTiles = [].concat(
    arrayMult [ 1, 1, 1, 2 ], 1
    arrayMult [ 1, 1, 1, 1, 1, 1, 1, 2, 6 ], 1
    arrayMult [ 1, 1, 1, 2 ], 1
    arrayMult [ 1, 1, 1, 2, 5 ], 1
    arrayMult [ 1, 1, 1, 2 ], 4
    arrayMult [ 1, 1, 1, 2, 5, 3, 5 ], 1
    arrayMult [ 1, 1, 1, 2 ], 4
    arrayMult [ 1, 1, 1, 2, 5 ], 1
    arrayMult [ 1, 1, 1, 2 ], 1
    arrayMult [ 1, 1, 1, 1, 1, 1, 1, 2, 6 ], 1
    arrayMult [ 1, 1, 1, 2 ], 1
  )

  # The overall game structure is defined as a sequence of screens.
  screens: [
    { name: 'screen', tiles:
      [].concat(
        arrayMult [ 1, 1, 1, 2 ], 12
        arrayMult [ 1, 1, 1, 1, 2 ], 1
      )}
    require './screens/intro'
    require './screens/intro2'
    { name: 'screen', tiles:
      [].concat(
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 2, 5 ], 1
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 1, 2 ], 1
      )}
    require './screens/canvas'
    { name: 'screen', tiles:
      [].concat(
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 2, 5 ], 1
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 1, 2 ], 1
      )}
    require './screens/audio'
    { name: 'screen', tiles:
      [].concat(
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 2, 5 ], 1
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 1, 2 ], 1
      )}
    require './screens/webgl'
    { name: 'screen', tiles:
      [].concat(
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 2, 5 ], 1
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 1, 2 ], 1
      )}
    { name: 'hall', title: 'three.js', subtitle: 'mrdoob.github.com/three.js', tiles: hallTiles }
    { name: 'hall', title: 'Ejecta', subtitle: 'impactjs.com/ejecta', tiles: hallTiles }
    { name: 'hall', title: 'CreateJS suite', subtitle: 'createjs.com (EaselJS, SoundJS)', tiles: hallTiles }
    { name: 'hall', title: 'socket.io', tiles: hallTiles }
    { name: 'hall', title: 'WebRTC', subtitle: 'and WebRTC.io', tiles: hallTiles }
    { name: 'hall', title: 'Backbone.js', subtitle: 'backbonejs.org/', tiles: hallTiles }
    { name: 'screen', tiles:
      [].concat(
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 2, 5 ], 1
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 1, 2 ], 1
      )}
    require './screens/caves'
    { name: 'screen', tiles:
      [].concat(
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 2, 5 ], 1
        arrayMult [ 1, 1, 1, 2 ], 5
        arrayMult [ 1, 1, 1, 1, 1, 2 ], 1
      )}
    { name: 'hall', title: 'You win!', highscores: yes, tiles: hallTiles }
    { name: 'screen', tiles:
      [].concat(
        arrayMult [ 1, 1, 1, 2 ], 3
      )}
  ]

  # Solid: 1: left, 2: right, 4: top, 8: bottom
  tileKey:
    0: { solid: 0x0 }
    1: { solid: 0xf, name: 'dirt' }
    2: { solid: 0xf, name: 'dirtgrass' }
    3: { solid: 0x4, name: 'floatgrass' }
    4: { solid: 0xf, name: 'noteblock' }
    5: { solid: 0x0, name: 'easteregg' }
    6: { solid: 0x0, name: 'torch' }

  offset = 0
  screenByX = []
  for s, idx in @::screens
    s.offset = offset
    if s.tiles
      s.width = s.tiles.length
    offset += s.width
    for w in [0...s.width]
      screenByX.push idx
    # s.smallStep = s.module? @, s

  parse: (response) ->
    return response unless response?
    @users.update response.users if response.users?
    delete response.users
    response

  simulate: (deltaTime) ->
    @clock += deltaTime
    stepSize = 1 / 60
    while @clock > 0
      @clock -= stepSize
      @smallStep stepSize
    return

  getScreen: -> @screens[@screen]

  getColumn: (x) ->
    # x must be an integer.
    s = @screens[screenByX[x]]
    s?.tiles[x - s.offset]

  beget = (parent) ->
    F = ->
    F:: = parent
    new F

  tileKey = (x, y) -> "#{x},#{y}"

  getTileObject: (x, y) ->
    @tileCache[tileKey x, y] ?= beget @getTile x, y

  getTile: (x, y) ->
    # x and y must be integers.
    @tileCache[tileKey x, y] or
    @tileKey[@getColumn(x)?[y] or 0]

  addUser: (user) ->
    scr = @getScreen()
    user.pos[0] = scr.offset + scr.width * (Math.random() * 0.2 + (1-0.2)/2)
    user.pos[1] = 9
    @users.add user

  smallStep: (deltaTime) ->
    if @users.length > 0
      avg = 0
      avg += user.pos[0] for user in @users.models
      avg /= @users.length
      @avg = avg
      user.smallStep @, deltaTime for user in @users.models

    # Manage screen transitions.
    TRANSITION_WAIT = 1
    TRANSITION_TOTAL = TRANSITION_WAIT + 1
    screenDef = @screens[@screen]
    screenTimer = @screenTimer
    if screenTimer is -1
      screenChange = 0
      for user in @users.models
        screenChange += user.screenChange

      threshold = @users.length * 0.35
      screenChange = if screenChange > 0
        if screenChange > threshold then 1 else 0
      else
        if -screenChange > threshold then -1 else 0

      newScreen = Math.max 0, Math.min @screens.length - 1, @screen + screenChange
      if newScreen isnt @screen
        @screen = newScreen
        @screenTimer = 0
    else
      for user, i in @users.models
        deadline = TRANSITION_WAIT + i / @users.length
        if screenTimer >= deadline
          # Pop!
          if user.pos[0] < screenDef.offset
            user.pos[0] = screenDef.offset + 2.5
          else if user.pos[0] > screenDef.offset + screenDef.width
            user.pos[0] = screenDef.offset + screenDef.width - 2.5
          else continue
          for id, y in @getColumn Math.floor user.pos[0]
            break unless @tileKey[id].solid
          user.pos[1] = y + 0.5
          user.vel[0] = user.vel[1] = 0
      screenTimer += deltaTime
      @screenTimer = if screenTimer < TRANSITION_TOTAL then screenTimer else -1

    @screens[@screen].smallStep? deltaTime
    return

  moveScreenLeft: ->
    newScreen = Math.max 1, @screen - 1
    @save { screen: newScreen, screenTimer: 0 }, { patch: yes }

  moveScreenRight: ->
    newScreen = Math.min @screens.length - 2, @screen + 1
    @save { screen: newScreen, screenTimer: 0 }, { patch: yes }
