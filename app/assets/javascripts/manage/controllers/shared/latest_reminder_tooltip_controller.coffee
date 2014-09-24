class window.App.LatestReminderTooltipController extends Spine.Controller

  events:
    "mouseenter .latest-reminder-cell": "onEnter"

  onEnter: (e)=>

    trigger = $(e.currentTarget)

    tooltip = new App.Tooltip
      el: trigger
      content: App.Render "views/loading", {size: "micro"}

    App.LatestReminder.ajaxFetch
      data: $.param
        user_id: trigger.data "user-id"
        visit_id: trigger.data "visit-id"
    .done((data) => tooltip.update App.Render "manage/views/inventory_pools/latest_reminder/tooltip", data)
    .fail => tooltip.update _jed("No reminder yet")
