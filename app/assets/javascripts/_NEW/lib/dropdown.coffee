###

App.Dropdown

This script provides functionalities for dropdowns.

It prevents that a dropdown is immediatly shown when hovered (containing delay)
It prevents that a dropdown is immediatly destroy when mouse

###

App.Dropdown ?= {}

class App.Dropdown.Hover

  @showDelay = 80
  @hideDelay = 200
  @current = undefined

  constructor: (e)->
    @holder = $(e.currentTarget)
    @dropdown = @holder.find(".dropdown")
    App.Dropdown.Hover.current = @
    setTimeout =>
      do @validate
    , App.Dropdown.Hover.showDelay

  validate: =>
    if App.Dropdown.Hover.current == @
      @dropdown.show()

jQuery -> 
  $(document).on "mouseenter", ".dropdown-holder", (e)-> 
    if App.Dropdown.Hover.current?
      if App.Dropdown.Hover.current.holder[0] != $(e.currentTarget)[0]
        App.Dropdown.Hover.current.dropdown.hide() 
      else
        clearTimeout App.Dropdown.Hover.hideTimer
    new App.Dropdown.Hover e
  $(document).on "mouseleave", ".dropdown-holder", (e)-> 
    App.Dropdown.Hover.current = undefined
    App.Dropdown.Hover.hideTimer = setTimeout (=> 
      $(e.currentTarget).find(".dropdown").hide()
      App.Dropdown.Hover.current = undefined
    ), App.Dropdown.Hover.hideDelay