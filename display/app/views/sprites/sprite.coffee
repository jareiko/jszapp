loadTexture = require '../loadtexture'

module.exports = class Sprite extends THREE.Object3D

  geom = new THREE.PlaneGeometry 1, 1

  gridX: 1
  gridY: 1
  scaleX: 1
  scaleY: 1

  constructor: ->
    super()
    @map = loadTexture @textureUrl if @textureUrl
    @map.magFilter = THREE.NearestFilter
    @material = new THREE.MeshLambertMaterial
      map: @map
      transparent: yes
      alphaTest: 0.4
      blending: THREE.NoBlending
    @material.offset = new THREE.Vector2 0, 0
    @material.repeat = new THREE.Vector2 1 / @gridX, 1 / @gridY
    @mesh = new THREE.Mesh geom, @material
    @mesh.scale.x = @scaleX
    @mesh.scale.y = @scaleY
    @add @mesh
    @animTime = 0

  setSprite: (frame) ->
    @material.offset.x = (frame.c[0] + 0.5 * (1-frame.s[0])) / @gridX
    @material.offset.y = frame.c[1] / @gridY
    @material.repeat.x = frame.s[0] / @gridX
    @material.repeat.y = frame.s[1] / @gridY

  setAnimation: (name) ->
    anim = @anims[name]
    if @anim isnt anim
      @anim = anim
      @animFrame = 0
      @animTime = 0
      @setSprite @anim[0]

  update: (deltaTime) ->
    @animTime += deltaTime
    update = no
    while @animTime > (frame = @anim[@animFrame]).t
      @animTime -= frame.t
      @animFrame = (@animFrame + 1) % @anim.length
      update = yes
    if update
      @setSprite frame
