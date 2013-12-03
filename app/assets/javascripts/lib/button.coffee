class Button

  @disable: (trigger)->
    trigger = $ trigger
    multibutton = trigger.closest(".multibutton")
    if multibutton.length
      button = multibutton.children(".button")
      multibutton.attr("autocomplete", "off").attr("disabled", true)
      multibutton.find(".dropdown-toggle").attr("autocomplete", "off").attr("disabled", true)
      multibutton.find(".dropdown").trigger("mouseleave").hide()
    else
      button = trigger
    button.attr("autocomplete", "off").attr("disabled", true)
    return button

  @enable: (trigger)->
    trigger = $ trigger
    multibutton = trigger.closest(".multibutton")
    if multibutton.length
      button = multibutton.children(".button")
      multibutton.removeAttr "disabled"
      multibutton.attr("autocomplete", "off")
      multibutton.find(".dropdown-toggle").removeAttr "disabled"
    else
      button = trigger
    button.attr("autocomplete", "off")
    button.removeAttr "disabled"
    return button

App.Button = Button