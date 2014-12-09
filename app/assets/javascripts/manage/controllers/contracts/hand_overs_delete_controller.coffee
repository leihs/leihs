class window.App.HandOversDeleteController extends Spine.Controller

  events:
    "click [data-hand-over-delete]": "onClick"

  onClick: (e)=>
    trigger = $ e.currentTarget
    data = trigger.closest("[data-id]").data()
    handOver = App.Visit.findOrBuild data
    handOver.destroy(
      success: (obj, response)->
        button = App.Button.disable trigger
        button.html App.Render "manage/views/hand_overs/deleted"
    )
