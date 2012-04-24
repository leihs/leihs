###

Max Quantity

This script provides functionalities to compute the max quantity of an array of lines
 
###

class MaxQuantity
  
  constructor: (lines_data) ->
    @value = Underscore.reduce lines_data, (mem, line) -> 
      mem + line.quantity 
    ,0
    return this
    
window.MaxQuantity = MaxQuantity