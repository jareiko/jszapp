Easel = require '../sprites/easel'
Paintbrush = require '../sprites/paintbrush'
Screen = require './screen'
Sprite = require('../sprites/sprite')

class Canvas extends Sprite
  scaleX: 8
  scaleY: 8

  constructor: ->
    canvas = document.createElement 'canvas'
    canvas.width = 256
    canvas.height = 256
    @ctx = canvas.getContext '2d'
    @ctx.fillStyle = "rgba(255, 255, 255, 0.5)"
    @ctx.fillRect 0, 0, 256, 256
    @map = new THREE.Texture canvas
    @map.needsUpdate = yes
    super
    @material.blending = THREE.NormalBlending
    # @mesh.position.x = @scaleX / 2
    # @mesh.position.y = @scaleY / 2

  paint: (x, y, color) ->
    # Project world space to canvas space.
    m = @mesh.matrixWorld.elements
    a = m[0]
    b = m[1]
    c = m[4]
    d = m[5]
    det = 1 / (a * d - b * c)
    ia = d * det
    ib = -b * det
    ic = -c * det
    id = a * det

    x -= m[12]
    y -= m[13]
    x1 = ((x * ia + y * ic) + 0.5) * 256
    y1 = (-(x * ib + y * id) + 0.5) * 256

    @ctx.beginPath()
    @ctx.arc x1, y1, 4, 0, Math.PI * 2, true
    @ctx.fillStyle = color
    @ctx.fill()
    @ctx.closePath()

    @map.needsUpdate = yes

module.exports = class CanvasView extends Screen
  constructor: (@screen, @engine) ->
    super
    engine.addCenterText @, screen, 0.8, 0x009000, 2.1, "<canvas>"
    easel = new Easel()
    easel.position.x = screen.width / 2
    easel.position.y = 4
    easel.mesh.renderDepth = 2
    @canvas = new Canvas()
    @canvas.position.y = 4.5
    # @canvas.mesh.renderDepth = 0.3
    easel.add @canvas
    @add easel
    # @add @canvas

  update: (deltaTime) ->
    overall = @engine.time * 0.2
    diff = (Math.sin 4 * overall) / 4
    @canvas.mesh.rotation.z = overall - diff
    for id, userSprite of @engine.userSprites
      data = userSprite.getData(@id)
      onScreen = @screen.offset + 2 < userSprite.position.x < @screen.offset + @screen.width - 2

      if onScreen and not data.paintbrush
        paintbrush = new Paintbrush()
        paintbrush.position.y = 0.5
        userSprite.add paintbrush
        data.paintbrush = paintbrush
        r = Math.floor Math.random() * 255
        g = Math.floor Math.random() * 255
        b = Math.floor Math.random() * 255
        paintbrush.material.ambient.r = r / 255
        paintbrush.material.ambient.g = g / 255
        paintbrush.material.ambient.b = b / 255
        data.color = "rgba(#{r},#{g},#{b},0.25)"
      else if data.paintbrush and not onScreen
        userSprite.remove data.paintbrush
        delete data.paintbrush

      if onScreen
        pbPosX = userSprite.position.x
        pbPosY = userSprite.position.y + 2
        @canvas.paint pbPosX, pbPosY, data.color
    return
