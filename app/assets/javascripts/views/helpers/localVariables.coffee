do ->
  vars = {}

  $.views.helpers
    setvar: (key, value) ->
      vars[key] = value
      return ""
    getvar: (key) -> vars[key]
