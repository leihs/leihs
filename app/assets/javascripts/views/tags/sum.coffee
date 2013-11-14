$.views.tags
  
  sum: (data, attr) -> _.reduce data, ((mem, r)-> mem+r[attr]), 0