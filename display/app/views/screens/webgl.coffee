Longcat = require '../sprites/longcat'
Screen = require './screen'
Terrain = require '../sprites/terrain'
loadTexture = require '../loadtexture'

module.exports = class WebGL extends Screen

  constructor: (@screen, @engine) ->
    super
    geom = new THREE.CubeGeometry 2, 2, 2, 1, 1, 1
    mat = new THREE.MeshLambertMaterial
      map: loadTexture "textures/WebGL.png"
      alphaTest: 0.5

    for x in [0..3]
      for y in [0..2]
        for z in [0..1]
          cube = new THREE.Mesh geom, mat
          cube.position.set 10 + x * 6, 8 + y * 4, -7 + z * 5
          @add cube
    @cube = new THREE.Mesh geom, mat
    @add @cube

    for x in [2...screen.width-1]
      grass = new Terrain
      grass.setSprite { c: [3, 3], s: [1, 1] }
      grass.position.set x - 0.5, 7, -0.4
      grass.rotation.x = -Math.PI / 2
      @add grass

    @add longcat = new Longcat
    longcat.position.set 40, 7, -4

  update: (deltaTime) ->
    @cube.rotation.x += deltaTime * 0.2
    @cube.rotation.y += deltaTime * 0.5
    @cube.rotation.z += deltaTime * 0.7
    phi = @engine.time * 0.3
    @cube.position.set(20 + 10 * Math.sin phi * 1
                       13 +  4 * Math.sin phi * 1.3
                        0 +  2 * Math.sin phi * 1.7)

    distance = @engine.game.avg - (@screen.offset + @screen.width / 2)
    distAbs = Math.min 1, Math.abs distance * 2 / @screen.width
    distSq = distAbs * distAbs
    distCubic = 3 * distSq - 2 * distSq * distAbs
    camTilt = 1 - distCubic

    @engine.camera.position.y = 7 + camTilt * 5
    @engine.camera.position.z = 10 - camTilt * 3
    @engine.camera.rotation.x = camTilt * -0.2
