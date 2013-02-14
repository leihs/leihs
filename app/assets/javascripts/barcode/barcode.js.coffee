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
  @known_prefix =
    "C": "open_contract"
  
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
    target = if $("input:focus, textarea:focus").length then $("input:focus:first, textarea:focus:first") else $(".barcode_target:last")
    # check for a known barcode prefix and execute command
    prefix = Barcode.scanner_input.match(/^\s\w\s/).join().replace(/\s/g, "") if Barcode.scanner_input.match(/^\s\w\s/)?
    code = Barcode.scanner_input.replace(/^\s\w\s/, "")
    if target.is(":not(:focus)") and @known_prefix[prefix]? and (typeof(@[@known_prefix[prefix]]) == "function")
      @[@known_prefix[prefix]].call @, code
      return true
    # execute code input
    $(target).val("").val code
    # submit only if not prevented
    unless target.closest(".prevent-scanner-submit").length
      $(target).closest("form").submit()
  
  @open_contract: (id)->
    loading_dialog = Dialog.add
      content: $.tmpl "tmpl/dialog/loading"
      dialogClass: "loading"
    $.ajax
      url: "/backend/inventory_pools/#{currentInventoryPool.id}/contracts/#{id}.json"
      type: "GET",
      success: (data)->
        Dialog.add
          content: $.tmpl "tmpl/dialog/documents/contract", data
          dialogClass: "medium documents contract",
          dialogId: "print"
      complete: ->
        loading_dialog.dialog "close"
    
window.Barcode = Barcode