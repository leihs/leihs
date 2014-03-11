###
  
  User

###

class window.App.User extends Spine.Model

  @configure "User", "id", "firstname", "lastname", "settings", "groupIds", "unique_id", "delegator_user_id"

  @hasMany "contracts", "App.Contract", "user_id"
  @hasMany "accessRights", "App.AccessRight", "user_id"
  @belongsTo "delegator_user", "App.User", "delegator_user_id"

  @extend Spine.Model.Ajax
  @extend App.Modules.FindOrBuild

  setStartScreen: (path)-> $.post "/manage/users/#{App.User.current.id}/set_start_screen", {path: path}        

  name: -> [@firstname, @lastname].join(" ")

  isAdmin: -> _.some @.accessRights().all(), (ar) -> ar.role == "admin"

  accessRight: ->
    _.find @.accessRights().all(), (ar) -> ar.inventory_pool_id == App.InventoryPool.current?.id and not ar.deleted_at

  roleName: ->
    if App.InventoryPool.current?
      ar = @.accessRight()
      ar?.name() ? _jed "No access"
    else
      if @.isAdmin()
        _jed "Administrator"

  suspendedUntil: -> @.accessRight()?.suspended_until

  suspended: ->
    if @.suspendedUntil() then moment(@.suspendedUntil()).diff(moment(), "days") >= 0 else false

  isDelegation: -> @.delegator_user_id ? false

  @fetchDelegators: (users, callback = null)->
    delegations = _.filter users, (r)-> r.isDelegation()
    delegator_user_ids = _.uniq _.map delegations, (r)-> r.delegator_user_id
    if delegator_user_ids.length
      App.User.ajaxFetch
        data: $.param
          ids: delegator_user_ids
      .done ->
        callback?()
    else
      callback?()
