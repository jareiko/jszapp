module.exports =
  syncSocket: (socket) ->
    (method, model, options) ->
      attrs = switch method
        when 'create', 'update', 'patch'
          options.attrs or model.toJSON()
        else {}
      attrs.id = model.id if model.id?
      type = model.constructor.name
      socket.emit 'sync', { method, type, attrs }, (reply) ->
        if reply?.error
          console.warn "iosync error: #{reply?.error}"
          options.error? model, reply?.error, options
        else
          options.success? model, reply?.model, options
        return
      return
