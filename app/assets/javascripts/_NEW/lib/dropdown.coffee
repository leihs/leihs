###

App.Dropdown

This script provides functionalities for dropdowns.

It prevents that a dropdown is immediatly shown when hovered (containing delay)
It prevents that a dropdown is immediatly destroy when mouse

###

App.Dropdown ?=
  currentDropdown: undefined
  currentHolder: undefined
  currentHideTimer: undefined
  mouseOver: false
  showDelay: 120
  hideDelay: 250

jQuery -> 

  $(document).on "mouseenter", ".dropdown-holder", (e)-> 
    holder = $(e.currentTarget)
    dropdown = holder.find(".dropdown")
    App.Dropdown.currentDropdown = dropdown
    App.Dropdown.mouseOver = true
    setTimeout =>
      if App.Dropdown.currentDropdown? and
      App.Dropdown.mouseOver and
      App.Dropdown.currentDropdown[0] == dropdown[0]
        App.Dropdown.currentHideTimer = undefined
        do dropdown.show
    , App.Dropdown.showDelay

  $(document).on "mouseenter", ".dropdown", (e)-> 
    dropdown = $(e.currentTarget)
    if App.Dropdown.currentDropdown? and
    App.Dropdown.currentDropdown[0] == dropdown[0]
      clearTimeout App.Dropdown.currentHideTimer

  $(document).on "mouseleave", ".dropdown-holder", (e)-> 
    holder = $(e.currentTarget)
    dropdown = holder.find(".dropdown")
    App.Dropdown.mouseOver = false
    App.Dropdown.currentHideTimer = setTimeout (=>
      do dropdown.hide
    ), App.Dropdown.hideDelay