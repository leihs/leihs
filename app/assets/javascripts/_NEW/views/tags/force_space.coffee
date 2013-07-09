$.views.tags
  
  forceSpaces: (text) ->
    text.replace /[^\w\.]/, (match)-> " #{match} "