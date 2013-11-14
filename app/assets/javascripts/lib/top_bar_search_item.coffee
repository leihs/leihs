###

App.TopBarSearchItem

This script provides functionalities for the interactivity with the topbar search item.

###

class window.App.TopBarSearchItem

  constructor: (options)->
    @el = options.el
    @input = @el.find "input[type='text']"
    do @delegateEvents

  delegateEvents: =>
    @input.on "focus", => @el.addClass("active")
    @input.on "blur", => 
      @blurTimeout = setTimeout (=>
        @el.removeClass("active"))
      , 100
    @el.on "click", "[type='submit']", @clickOnSubmit
    @el.on "submit", @submit

  clickOnSubmit: =>
    clearTimeout @blurTimeout if @blurTimeout?
    @el.addClass("active")
    @input.focus()

  submit: (e)=>
    unless @input.val().length
      e.preventDefault()