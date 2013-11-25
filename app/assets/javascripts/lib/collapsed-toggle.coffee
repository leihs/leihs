###

App.CollapsedToggle

This script provides functionalities for toggle a collapsed container

###

jQuery -> 

  $(document).on "click", "[data-collapsed-toggle]", (e)-> 
    trigger = $ e.currentTarget
    target = $ trigger.data("collapsed-toggle")
    target.toggleClass "expanded"
    trigger.toggleClass "expanded"