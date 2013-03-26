bb = Backbone ? require 'backbone'

module.exports = class BaseModel extends bb.Model

  # http://www.narrativescience.com/blog/automatically-creating-getterssetters-for-backbone-models/
  initialize: ->
    super
    buildGetter = (name) ->
      -> @get name
    buildSetter = (name) ->
      (value) -> @set name, value
    for attr in @attributeNames
      Object.defineProperty @, attr,
        get: buildGetter attr
        set: buildSetter attr
