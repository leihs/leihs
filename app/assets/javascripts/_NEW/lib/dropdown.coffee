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
  showDelay: 120
  hideDelay: 250

jQuery -> 

  $(document).on "mouseenter", ".dropdown-holder", (e)-> 
    holder = $(e.currentTarget)
    dropdown = holder.find(".dropdown")
    App.Dropdown.currentDropdown = dropdown
    holder.addClass "mouseover"
    do (holder, dropdown)->
      setTimeout =>
        if App.Dropdown.currentDropdown? and
        holder.hasClass("mouseover") and
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
    holder.removeClass "mouseover"
    App.Dropdown.currentHideTimer = setTimeout (=>
      unless holder.hasClass("mouseover")
        do dropdown.hide 
    ), App.Dropdown.hideDelay