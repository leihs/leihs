$.views.tags
  
  param: (data, attribute) -> 
    if attribute?
      h = {}
      h[attribute] = data
      $.param h
    else
      $.param data
    