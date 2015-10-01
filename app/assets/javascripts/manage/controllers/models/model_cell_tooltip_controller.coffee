class window.App.ModelCellTooltipController extends Spine.Controller

  events:
    "mouseenter [data-type='model-cell']": "onEnter"

  onEnter: (e)=>
    trigger = $(e.currentTarget)
    new App.Tooltip
      el: trigger.closest("[data-type='model-cell']")
      content: App.Render "manage/views/models/tooltip", App.Model.findOrBuild trigger.data()