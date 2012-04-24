###

  Barcode
  
  This script provides functionalities for barcode fields 
  and implements recognizing inputs coming from a barcode scanner
  
###

jQuery ->
  Barcode.setup()

class Barcode
  
  @scanner_max_delay = 50;
  @scanner_delay_timer;
  @scanner_input = "";
  
  @setup: ->
    $(window).keypress (e)->
      e = e || window.event
      char_code = if (typeof e.which == "number") then e.which else e.keyCode  
      _char = String.fromCharCode(char_code)
      if (char_code == 13) and (Barcode.scanner_input != "")
        e.preventDefault()
        Barcode.execute()
        Barcode.scanner_input = ""
      else
        Barcode.scanner_input += _char
        window.clearTimeout Barcode.scanner_delay_timer  
        Barcode.scanner_delay_timer = window.setTimeout ()-> 
          Barcode.scanner_input = ""
        , Barcode.scanner_max_delay

  @execute: ->
    # if a input field is focused user is interest for insert the barcode data in the focused input
    if $("input:focus, textarea:focus").length
      target = $("input:focus:first, textarea:focus:first")
    else
      target = $(".barcode_target:last")
    # execute  
    $(target).val("").val Barcode.scanner_input
    $(target).closest("form").submit()
  
window.Barcode = Barcode