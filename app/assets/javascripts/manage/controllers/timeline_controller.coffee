class window.App.TimeLineController extends Spine.Controller

  events:
    "click [data-open-time-line]": "show"

  show: (e)->
    trigger = $ e.currentTarget
    model = App.Model.find trigger.data "model-id"
    tmpl = App.Render "manage/views/models/timeline_modal", model
    @modal = new App.Modal tmpl
    @modal.el.find("iframe").load @onload

  onload: => 
    @modal.el.find("#loading").remove()