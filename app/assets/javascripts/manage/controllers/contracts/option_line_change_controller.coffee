class window.App.OptionLineChangeController extends Spine.Controller

  events:
    "change [data-line-type='option_line'] [data-line-quantity]": "change"
    "focus [data-line-type='option_line'] [data-line-quantity]": "focus"

  constructor: ->
    super
    new PreChange "[data-line-type='option_line'] [data-line-quantity]"

  focus: (e)=>
    target = $ e.currentTarget
    target.select()

  change: (e)=>
    target = $(e.currentTarget)
    reservation = App.Reservation.find target.closest("[data-id]").data("id")
    new_quantity = parseInt(target.val())
    if new_quantity > 0 and new_quantity != reservation.quantity
      reservation.updateAttributes {quantity: new_quantity}
      if e.type == "preChange"
        # NOTE spine updateAttributes loses the input focus, then backspace drives to the previous page
        # we refocus the field, but we cannot use the currentTarget because the DOM has been changed
        $("[data-line-type='option_line'][data-id='#{reservation.id}'] [data-line-quantity]:first").focus()
    else
      target.val(reservation.quantity)
