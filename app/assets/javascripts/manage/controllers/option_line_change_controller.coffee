class window.App.OptionLineChangeController extends Spine.Controller

  events:
    "change [data-line-type='option_line'] [data-line-quantity]": "change"
    "delayedChange [data-line-type='option_line'] [data-line-quantity]": "change"
    "focus [data-line-type='option_line'] [data-line-quantity]": "focus"

  constructor: ->
    super
    new DelayedChange "[data-line-type='option_line'] [data-line-quantity]"

  focus: (e)=>
    target = $ e.currentTarget
    target.select()

  change: (e)=>
    target = $(e.currentTarget)
    contractLine = App.ContractLine.find target.closest("[data-id]").data("id")
    contractLine.updateAttributes {quantity: target.val()}