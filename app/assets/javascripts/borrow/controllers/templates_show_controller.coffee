class window.App.TemplatesShowController extends Spine.Controller

  events: 
    "change input[type='number']": "validateNumber"
    "preChange input[type='number']": "validateNumber"

  constructor: ->
    super
    do @setupNumbers

  setupNumbers: =>
    @el.find("input[type='number']").preChange()

  validateNumber: (e)=>
    target = $(e.currentTarget)
    if parseInt(target.val()) > parseInt(target.attr("max"))
      target.val(target.attr("max"))
    else if parseInt(target.val()) < parseInt(target.attr("min"))
      target.val(target.attr("min"))
    else if target.val().match(/\D/)
      target.val(target.attr("min"))
