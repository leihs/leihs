class Category

  @url: => "/backend/inventory_pools/#{currentInventoryPool.id}/categories"

  @fetch: (callback)->
    $.ajax(
      url: "#{@url()}.json"
    ).done (data)->
      callback(data) if callback?


window.App.Category = Category