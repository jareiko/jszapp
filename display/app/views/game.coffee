Bunny = require './sprites/bunny'
Cloud = require './sprites/cloud'
GamepadManager = require 'common/gamepadmanager'
util = require 'common/util'

createScreen = (def, engine) ->
  View = require "./screens/#{def.name}"
  new View def, engine

CloudSystem = (scene, camera) ->
  maxRange = 100

  clouds = for i in [0..4]
    scene.add cloud = new Cloud
    cloud.position.x = Math.random() * maxRange
    cloud.position.y = Math.random() * 30 + 9
    cloud.position.z = (i/4) * 10 - 50
    cloud.mesh.renderDepth = -cloud.position.z
    cloud.vel = Math.random() * 2 - 1
    cloud

  @update = (deltaTime) ->
    camPosX = camera.position.x
    for cloud in clouds
      x = cloud.position.x
      x += cloud.vel * deltaTime
      if x < camPosX - maxRange or x > camPosX + maxRange
        cloud.vel = Math.random() * 4 - 2
        x = camPosX + if cloud.vel < 0 then maxRange else -maxRange
      cloud.position.x = x
    return
  return

module.exports = (game, renderer, audio) ->
  hzFov = 70
  camera = new THREE.PerspectiveCamera hzFov, 1, 1, 200
  camera.position.x = 0
  camera.position.y = 7
  camera.position.z = 10
  camVelX = 0
  do @resize = ->
    width = window.innerWidth
    height = window.innerHeight
    camera.aspect = width / height
    hmm = camera.aspect + 0.2
    camera.fov = hzFov / Math.max 1, hmm / 1.777
    camera.updateProjectionMatrix()
    renderer.setSize width, height

  scene = new THREE.Scene()

  scene.add new THREE.AmbientLight 0xffffff

  clouds = new CloudSystem scene, camera

  # gridGeom = new THREE.PlaneGeometry 200, 20, 200, 20
  # gridMat = new THREE.MeshBasicMaterial
  #   wireframe: true
  #   color: 0x000000
  # gridMesh = new THREE.Mesh gridGeom, gridMat
  # gridMesh.position.set 100, 10, 0
  # scene.add gridMesh

  engine =
    camera: camera
    game: game
    gameView: @
    time: 0

  engine.makeTextMesh = (text, opts = {}) ->
    textShapes = THREE.FontUtils.generateShapes text,
      font: "helvetiker"
      weight: "bold"
      size: opts.size or 0.3

    textGeom = new THREE.ShapeGeometry textShapes
    textMat = new THREE.MeshLambertMaterial
      ambient: opts.color or 0xffffff
      color: opts.color or 0xffffff

    mesh = new THREE.Mesh textGeom, textMat
    mesh.position.x = mesh.geometry.shapebb.centroid.x * -0.5
    mesh
  engine.addText = (parent, size, color, x, y, text) ->
    txt = engine.makeTextMesh text, { size, color }
    txt.position.x += x - size * 0.25
    txt.position.y = y
    txt.renderDepth = -0.1
    parent.add txt
    txt
  engine.addCenterText = (parent, screen, size, color, y, text) ->
    @addText parent, size, color, screen.width / 2, y, text

  offset = 0
  # @screenViews = []
  @screenViews = for screen in game.screens
    screenView = createScreen screen, engine, game
    screenView.position.x = offset
    scene.add screenView
    offset += screen.width
    screenView

  userSprites = engine.userSprites = Object.create null

  game.users.on 'add', (user, users, options) ->
    # console.log "added user #{user.id}: #{user.name}"
    sprite = userSprites[user.id] = new Bunny()
    # sprite.data = Object.create null
    sprite.mesh.position.z = 0.1
    sprite.getData = do ->
      data = {} #Object.create null
      (id) -> data[id] ?= {} #Object.create null
    textMesh = null
    updateMesh = ->
      sprite.remove textMesh if textMesh?
      if user.name.length > 0
        textMesh = engine.makeTextMesh user.name
        textMesh.position.y = 1.2
        sprite.add textMesh
      else
        textMesh = null
    updateMesh()
    user.on 'change:name', updateMesh
    scene.add sprite

  game.users.on 'remove', (user, users, options) ->
    # console.log "removed user #{user.id}: #{user.name}"
    scene.remove userSprites[user.id]
    delete userSprites[user.id]

  syncUsers = (deltaTime) ->
    game.users.each (user) ->
      sprite = userSprites[user.id]
      sprite.position.x = user.pos[0]
      sprite.position.y = user.pos[1]
      sprite.position.z = user.pos[2]
      if user.vel[1] isnt 0
        if user.control & user.CONTROL.LEFT
          sprite.setAnimation 'jumpleft'
        else if user.control & user.CONTROL.RIGHT
          sprite.setAnimation 'jumpright'
        else if user.vel[1] > 0
          sprite.setAnimation 'earsdown'
        else
          sprite.setAnimation 'earsup'
      else if user.control & user.CONTROL.LEFT and not (user.control & user.CONTROL.RIGHT)
        sprite.setAnimation 'left'
      else if user.control & user.CONTROL.RIGHT and not (user.control & user.CONTROL.LEFT)
        sprite.setAnimation 'right'
      else
        sprite.setAnimation 'idle'
      sprite.update deltaTime
    return

  MAP_RANGE = (value, premin, premax, postmin, postmax) ->
    (value - premin) * (postmax - postmin) / (premax - premin) + postmin

  gpm = new GamepadManager
  gpm.on 'gamepadconnected', (gamepad) ->
    gamepad.on 'buttonchange', (button, value, prevValue) ->
      switch button
        when 6
          game.moveScreenLeft() if value >= 0.5 and prevValue < 0.5
        when 7
          game.moveScreenRight() if value >= 0.5 and prevValue < 0.5

  @update = (deltaTime) ->
    engine.time += deltaTime
    game.simulate deltaTime

    gpm.update()

    syncUsers deltaTime

    min = +Infinity
    max = -Infinity
    avg = 0
    stddev = 0
    if game.users.length > 0
      for user in game.users.models
        pos = user.pos[0]
        avg += pos
        min = Math.min min, pos
        max = Math.max max, pos
      avg /= game.users.length

    camera.position.y = 7
    camera.position.z = 10

    # TODO: Update only current screen view?
    for screenView in @screenViews
      screenView.update? deltaTime

    pushOut = Math.max 0, (max - min) / 2 - 6
    camera.position.z += pushOut

    screenDef = game.screens[game.screen]

    left = screenDef.offset + 8
    right = screenDef.offset + screenDef.width - 8
    camTarget = Math.max left, Math.min right, avg
    camVelTarget = (camTarget - camera.position.x) * 5 - camVelX * 1
    camVelX = util.PULLTOWARD camVelX, camVelTarget, deltaTime * 5
    camera.position.x += camVelX * deltaTime

    clouds.update deltaTime

  @render = ->
    renderer.render scene, camera

  sfx = {}

  audio.loadBuffer 'sounds/note.mp3',    (buffer) -> sfx.note = buffer
  audio.loadBuffer 'sounds/hop.mp3',     (buffer) -> sfx.jump = buffer
  audio.loadBuffer 'sounds/collect.mp3', (buffer) -> sfx.collect = buffer

  game.on 'playsound', (sound, volume = 1, pitch = 1) ->
    buffer = sfx[sound]
    audio.playSound buffer, false, volume, pitch if buffer?

  return
