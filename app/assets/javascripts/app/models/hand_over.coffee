###
  
  HandOver

###

class HandOver

  @url: -> "/backend/inventory_pools/#{currentInventoryPool.id}/users/#{current_customer}/hand_over"

  @ajaxFetch: ->
    $.get("#{HandOver.url()}.json")

window.App.HandOver = HandOver