###

App.Modal

This script provides functionalities for display modal dialogs.

It also keeps track of existing dialogs to avoid multiple instances of the same dialog in the dom.

It also helps autofocusing fields that have the autofocus attribute.

###

class window.App.Modal

  @all = []

  constructor: (el)->
    @el = $(el)
    do @delegateEvents
    App.Modal.all.push @
    @el.modal 
      backdrop: 'static'

  delegateEvents: ->
    @el.on "hidden", => @destroy
    @el.on "shown", @shown
    $(window).on "resize", @setModalBodyMaxHeight
    @el.on "click", ".modal-close", => @destroy(true)
    
  setModalBodyMaxHeight: =>
    height = $(window).height() - @el.outerHeight() - ($(window).height()/100*20) + @el.find(".modal-body").height()
    height = 10 if height < 10
    @el.find(".modal-body").css "max-height", height

  destroy: (removeBackdrop)=>
    @el.remove()
    $(window).off "resize", @setModalBodyMaxHeight
    $(".modal-backdrop").remove() if removeBackdrop? and removeBackdrop

  shown: =>
    @el.addClass "ui-shown"
    @el.find("[autofocus=autofocus]").focus()
    do @setModalBodyMaxHeight    

  @destroyAll: (removeBackdrop)=> 
    modal.destroy(removeBackdrop) for modal in App.Modal.all