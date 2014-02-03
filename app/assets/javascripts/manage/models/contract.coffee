## Global

window.App.Contract.url = => "#{App.InventoryPool.url}/#{App.InventoryPool.current.id}/contracts"

## Prototype

window.App.Contract::approve = (comment)-> $.post "/manage/#{App.InventoryPool.current.id}/contracts/#{@id}/approve", {comment: comment}

window.App.Contract::unapprove = -> $.post "/manage/#{App.InventoryPool.current.id}/contracts/#{@id}/unapprove"

window.App.Contract::approve_anyway = (comment)-> $.post "/manage/#{App.InventoryPool.current.id}/contracts/#{@id}/approve", {force: true, comment: comment}

window.App.Contract::reject = (comment)-> $.post "/manage/#{App.InventoryPool.current.id}/contracts/#{@id}/reject", {comment: comment}

window.App.Contract::swapUser = (user_id)-> $.post "/manage/#{App.InventoryPool.current.id}/contracts/#{@id}/swap_user", {user_id: user_id}

window.App.Contract::sign = (data)-> $.post "#{App.InventoryPool.url}/#{App.InventoryPool.current.id}/contracts/#{@id}/sign", data

window.App.Contract::editPath = -> "#{App.Contract.url()}/#{@id}/edit"

window.App.Contract::handOverPath = -> "#{App.Contract.url()}/#{@id}/hand_over"
