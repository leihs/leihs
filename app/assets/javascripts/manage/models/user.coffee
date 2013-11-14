## Global

window.App.User.url = => if App.InventoryPool.current? then "/manage/#{App.InventoryPool.current.id}/users" else "/manage/users"

## Prototype

window.App.User::isSuspended = -> _.include App.InventoryPool.current.suspended_user_ids, @id

window.App.User::imageUrl = -> 
  # this is currently ZHDK only
  if App.UserImageUrl? and @extended_info and @extended_info.id
    App.UserImageUrl.replace(/{:id}/, @extended_info.id)