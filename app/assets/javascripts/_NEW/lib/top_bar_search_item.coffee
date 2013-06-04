###

App.TopBarSearchItem

This script provides functionalities for the interactivity with the topbar search item.

###

class window.App.TopBarSearchItem

  constructor: (options)->
    @el = options.el
    @input = @el.find "input[type='text']"
    do @delegateEvents

  delegateEvents: =>
    @input.on "focus", => @el.addClass("active")
    @input.on "blur", => @el.removeClass("active")