$.views.tags

  count: (number) ->
    result = ""
    for num in _.range(0, number)
      result += @tagCtx.render {count: num}
    result
