## Global

window.App.User.url = => if App.InventoryPool.current? then "/manage/#{App.InventoryPool.current.id}/users" else "/admin/users"

## Prototype

window.App.User::isSuspended = -> _.include App.InventoryPool.current.suspended_user_ids, @id
