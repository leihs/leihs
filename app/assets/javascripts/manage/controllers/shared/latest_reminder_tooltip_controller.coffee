class window.App.LatestReminderTooltipController extends Spine.Controller

  events:
    "mouseenter .latest-reminder-cell": "onEnter"

  onEnter: (e)=>

    trigger = $(e.currentTarget)

    tooltip = new App.Tooltip
      el: trigger
      content: App.Render "views/loading", {size: "micro"}

    App.LatestReminder.ajaxFetch
      url: "/manage/#{App.InventoryPool.current.id}/latest_reminder"
      data: $.param
        user_id: trigger.data "user-id"
        visit_id: trigger.data "visit-id"
    .done (data) =>
      if data.length
        tooltip.update App.Render "manage/views/inventory_pools/latest_reminder/tooltip", data
      else
        tooltip.update _jed("No reminder yet")


