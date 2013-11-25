class window.App.AccessRight extends Spine.Model

  @configure "AccessRight", "id", "role_id", "user_id", "inventory_pool_id", "suspended_until"
  @belongsTo "users", "App.User", "user_id"
  @belongsTo "role", "App.Role", "role_id"
  @extend Spine.Model.Ajax
  @url: => if App.InventoryPool.current? then "/manage/#{App.InventoryPool.current.id}/access_rights" else "/manage/access_rights"

  name: ->
    switch @.role().name
      when "admin" then _jed "Administrator"
      when "customer" then _jed "Customer"
      when "manager" then switch @.access_level
        when 1, 2 then _jed "Lending manager"
        when 3 then _jed "Inventory manager"
