class window.App.TimeLineController extends Spine.Controller

  events:
    "click [data-open-time-line]": "show"

  show: (e)->
    trigger = $ e.currentTarget
    id = parseInt trigger.data "model-id"
    model = ( App.Model.exists(id) or App.Software.find(id) )
    tmpl = App.Render "manage/views/models/timeline_modal", model
    @modal = new App.Modal tmpl
    @modal.el.find("iframe").load @onload

  onload: => 
    @modal.el.find("#loading").remove()
