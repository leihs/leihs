## Global

window.App.User.url = => if App.InventoryPool.current? then "/manage/#{App.InventoryPool.current.id}/users" else "/manage/users"

## Prototype

window.App.User::isSuspended = -> _.include App.InventoryPool.current.suspended_user_ids, @id

window.App.User::imageUrl = -> 
  if App.UserImageUrl? and @unique_id
    App.UserImageUrl.replace(/{:id}/, @unique_id)