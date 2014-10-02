class window.App.OptionLineChangeController extends Spine.Controller

  events:
    "change [data-line-type='option_line'] [data-line-quantity]": "change"
    "preChange [data-line-type='option_line'] [data-line-quantity]": "change"
    "focus [data-line-type='option_line'] [data-line-quantity]": "focus"

  constructor: ->
    super
    new PreChange "[data-line-type='option_line'] [data-line-quantity]"

  focus: (e)=>
    target = $ e.currentTarget
    target.select()

  change: (e)=>
    target = $(e.currentTarget)
    contractLine = App.ContractLine.find target.closest("[data-id]").data("id")
    new_quantity = parseInt(target.val())
    if new_quantity > 0 and new_quantity != contractLine.quantity
      contractLine.updateAttributes {quantity: new_quantity}
    else
      target.val(contractLine.quantity)