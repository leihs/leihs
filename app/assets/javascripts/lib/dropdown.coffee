###

App.Dropdown

This script provides functionalities for dropdowns.

It prevents that a dropdown is immediatly shown when hovered (containing delay)
It prevents that a dropdown is immediatly destroy when mouse leaves

###

App.Dropdown ?=
  showDelay: 120
  hideDelay: 250

jQuery -> 

  $(document).on "mouseenter", ".dropdown-holder", (e)-> 
    holder = $(e.currentTarget)
    dropdown = holder.find(".dropdown")
    holder.data "dropdown", dropdown
    dropdown.data "holder", holder
    holder.addClass "mouseover"
    do (holder, dropdown)->
      setTimeout =>
        if holder.hasClass("mouseover")
          clearTimeout dropdown.data("timer")
          dropdown.show().addClass("show")
      , App.Dropdown.showDelay

  $(document).on "mouseenter", ".dropdown", (e)-> 
    dropdown = $(e.currentTarget)
    clearTimeout dropdown.data("timer")

  $(document).on "mouseleave", ".dropdown", (e)-> 
    dropdown = $(e.currentTarget)
    dropdown.hide().removeClass("show")

  $(document).on "mouseleave", ".dropdown-holder", (e)-> 
    holder = $(e.currentTarget)
    dropdown = holder.data "dropdown"
    holder.removeClass "mouseover"
    if dropdown?
      dropdown.data "timer", setTimeout (=>
        unless holder.hasClass("mouseover")
          dropdown.hide().removeClass("show")
      ), App.Dropdown.hideDelay