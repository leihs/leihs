class window.App.HandOversDeleteController extends Spine.Controller

  events:
    "click [data-hand-over-delete]": "onClick"

  onClick: (e)=>
    trigger = $ e.currentTarget
    data = trigger.closest("[data-id]").data()
    handOver = App.HandOver.findOrBuild data
    button = App.Button.disable trigger
    button.html App.Render "manage/views/hand_overs/deleted"
    handOver.destroy()
