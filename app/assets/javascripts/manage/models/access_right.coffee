class window.App.AccessRight extends Spine.Model

  @configure "AccessRight", "id", "role", "user_id", "inventory_pool_id", "suspended_until"
  @belongsTo "users", "App.User", "user_id"
  @extend Spine.Model.Ajax
  @url: => if App.InventoryPool.current? then "/manage/#{App.InventoryPool.current.id}/access_rights" else "/admin/access_rights"

  @rolesHierarchy: ["customer", "group_manager", "lending_manager", "inventory_manager"]

  name: ->
    switch @.role
      when "admin" then _jed "Administrator"
      when "customer" then _jed "Customer"
      when "group_manager" then _jed "Group manager"
      when "lending_manager" then _jed "Lending manager"
      when "inventory_manager" then _jed "Inventory manager"

  @atLeastRole: (checkRole, atLeastRole) ->
    _.indexOf(@rolesHierarchy, checkRole) >= _.indexOf(@rolesHierarchy, atLeastRole) unless checkRole == "admin"
