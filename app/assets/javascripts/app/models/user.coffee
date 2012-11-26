###
  
  User can be customer(frontend) or manager/admin(backend)

###

class User

  constructor: (user)->
    @groups = user.groups

  groupIds: ->
    _.map @groups, (g)-> g.id

window.App.User = User