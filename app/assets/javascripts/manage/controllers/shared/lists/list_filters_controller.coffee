class window.App.ListFiltersController extends Spine.Controller

  events:
    "change": "reset"

  reset: => do @reset

  getData: => 
    data = {}
    for datum in $(':visible', @el).serializeArray()
      if datum.value.length and datum.value != "0"
        data[datum.name] = datum.value
    data
