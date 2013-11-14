Ajax = Spine.Ajax
Model = Spine.Model

__original__ = Spine.Ajax.generateURL

Spine.Ajax.generateURL = (object, args...) ->
  if object.className
    collection = object.className.toLowerCase() + 's'
    scope = Ajax.getScope(object)
  else
    if typeof object.constructor.url is 'string'
      collection = object.constructor.url
    else if typeof object.constructor.url is 'function'
      collection = object.constructor.url()
    else
      collection = object.constructor.className.toLowerCase() + 's'
    scope = Ajax.getScope(object) or Ajax.getScope(object.constructor)
  args.unshift(collection)
  args.unshift(scope)
  # construct and clean url
  path = args.join('/')
  path = path.replace /(\/\/)/g, "/"
  path = path.replace /^\/|\/$/g, ""
  # handle relative urls vs those that use a host
  if path.indexOf("../") isnt 0
    Model.host + "/" + path
  else
    path
