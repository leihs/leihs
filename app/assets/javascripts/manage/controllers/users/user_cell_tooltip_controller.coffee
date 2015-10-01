class window.App.UserCellTooltipController extends Spine.Controller

  events:
    "mouseenter [data-type='user-cell']": "onEnter"

  onEnter: (e)=>
    trigger = $(e.currentTarget)
    new App.Tooltip
      el: trigger.closest("[data-type='user-cell']")
      content: App.Render "manage/views/users/tooltip", App.User.findOrBuild trigger.data()