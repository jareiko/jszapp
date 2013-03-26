module.exports = do ->
  textureCache = Object.create null
  (url) ->
    textureCache[url] ?= THREE.ImageUtils.loadTexture url
