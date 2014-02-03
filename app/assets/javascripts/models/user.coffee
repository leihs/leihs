###
  
  User

###

class window.App.User extends Spine.Model

  @configure "User", "id", "firstname", "lastname", "settings", "groupIds", "unique_id"

  @hasMany "contracts", "App.Contract", "user_id"
  @hasMany "accessRights", "App.AccessRight", "user_id"

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
