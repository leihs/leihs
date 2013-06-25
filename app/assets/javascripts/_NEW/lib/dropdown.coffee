###

App.Dropdown

This script provides functionalities for dropdowns.

It prevents that a dropdown is immediatly shown when hovered (containing delay)

###

App.Dropdown ?= {}

class App.Dropdown.Hover

  @delay = 80
  @current = undefined

  constructor: (e)->
    @holder = $(e.currentTarget)
    @dropdown = @holder.find(".dropdown")
    App.Dropdown.Hover.current = @
    setTimeout =>
      do @validate
    , App.Dropdown.Hover.delay

  validate: =>
    if App.Dropdown.Hover.current == @
      @dropdown.show()

jQuery -> 
  $(document).on "mouseenter", ".dropdown-holder", (e)-> new App.Dropdown.Hover e
  $(document).on "mouseleave", ".dropdown-holder", (e)-> 
    $(e.currentTarget).find(".dropdown").hide()
    App.Dropdown.Hover.current = undefined