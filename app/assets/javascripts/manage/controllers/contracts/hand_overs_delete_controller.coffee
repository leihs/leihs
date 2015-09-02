class window.App.HandOversDeleteController extends Spine.Controller

  events:
    "click [data-hand-over-delete]": "onClick"

  onClick: (e)=>
    trigger = $ e.currentTarget
    id = trigger.closest("[data-id]").data('id')
    $.ajax
      url: "/manage/#{App.InventoryPool.current.id}/visits/#{id}"
      type: "post"
      data:
        _method: "delete"
      success: (response) =>
        button = trigger.closest(".line-actions")
        button.html App.Render "manage/views/hand_overs/deleted"
