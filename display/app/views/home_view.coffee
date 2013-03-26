App         = require 'application'
Audio       = require './audio'
View        = require './view'
template    = require './templates/home'
GameClient  = require './game'
Game        = require '../common/models/game'

createRenderer = ->
  renderer = new THREE.WebGLRenderer
    alpha: no
    antialias: no
    premultipliedAlpha: no
    clearColor: 0xaaccff
  renderer.autoClear = yes
  renderer.devicePixelRatio = 1
  #renderer.devicePixelRatio = 2  # Force 2 even on lo-density displays.
  renderer.setSize window.innerWidth, window.innerHeight
  renderer

createCanvas = (el) ->
  renderer = createRenderer()
  el.appendChild renderer.domElement

  audio = new Audio()

  game = App.game

  gameClient = new GameClient game, renderer, audio

  window.addEventListener 'resize', -> gameClient.resize()

  #document.addEventListener 'keydown', (event) -> game.onKeyDown event
  #document.addEventListener 'touchstart', (event) -> game.onTouchStart event

  lastTime = 0

  animate = (time) ->
    time *= 0.001
    deltaTime = time - lastTime
    if deltaTime > 0
      deltaTime = Math.min 0.1, deltaTime
      lastTime = time

      gameClient.update deltaTime
      gameClient.render()

    requestAnimationFrame animate

  animate 0

module.exports = class HomeView extends View
  id: 'home-view'

  #template: template

  afterRender: ->
    createCanvas @el
