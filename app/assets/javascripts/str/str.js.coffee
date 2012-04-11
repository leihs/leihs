###

String

This script provides functionalities for modify strings
 
###

class Str
  
  @sliced_trunc = ()->
    string = if arguments[0]? then arguments[0] else ""
    max_length = if arguments[1]? then arguments[1] else 20
    seperator = if arguments[2]? then arguments[2] else "..."
    
    if string.length > max_length
      string = string.slice(0, max_length/2)+seperator+string.slice(string.length - max_length/2, string.length)
    
    return string
            
window.Str = Str
