class window.App.Borrow.TemplatesShowController extends Spine.Controller

  events: 
    "change input[type='number']": "validateNumber"
    "delayedChange input[type='number']": "validateNumber"

  constructor: ->
    super
    do @setupNumbers

  setupNumbers: =>
    @el.find("input[type='number']").delayedChange()

  validateNumber: (e)=>
    target = $(e.currentTarget)
    if parseInt(target.val()) > parseInt(target.attr("max"))
      target.val(target.attr("max"))
    else if parseInt(target.val()) < parseInt(target.attr("min"))
      target.val(target.attr("min"))
    else if target.val().match(/\D/)
      target.val(target.attr("min"))
