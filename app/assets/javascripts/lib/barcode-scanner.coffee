class BarcodeScanner

  constructor: ->
    @actions = []
    @buffer = null
    @delay = 50
    @timer = null
  
  addChar: (char)=>
    @buffer ?= ""
    @buffer += char
    window.clearTimeout @timer
    @timer = window.setTimeout (=> @buffer = null), @delay

  addAction: (string, callback)=>
    string = "^#{string.replace(/\(.*?\)/ig, "(\\S*)")}$"
    regexp = new RegExp(string)
    @actions.push
      regexp: regexp
      callback: callback

  execute: =>
    activeElement = $ document.activeElement
    target = if activeElement.is("input, textarea") then activeElement else $("[data-barcode-scanner-target]:last")
    code = @buffer
    action = @getAction code
    if action?
      action.callback.apply target, @getArguments(code, action)
    else
      target.val("").val(code).focus()
      @submit target
    @buffer = null

  getAction: (code)=>
    for action in @actions
      if action.regexp.test code
        return action

  getArguments: (code, action)=>
    matches = action.regexp.exec(code)
    return matches[1..matches.length]

  keyPress: (e = window.event)=>
    charCode = if (typeof e.which == "number") then e.which else e.keyCode
    char = String.fromCharCode(charCode)
    if (charCode == 13) and @buffer?
      do e.preventDefault
      do @execute
    else
      @addChar char

  submit: (target)=>
    if not target.closest("[data-prevent-barcode-scanner-submit]").length
      target.closest("form").submit()

window.BarcodeScanner = new BarcodeScanner()

$(window).keypress window.BarcodeScanner.keyPress