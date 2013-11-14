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
    @isDestroyable = true
    do @delegateEvents
    App.Modal.all.push @
    App.Tooltip.hideAll()
    @el.modal 
      backdrop: true

  delegateEvents: ->
    @el.on "hidden", => @destroy
    @el.on "shown", @shown
    $(window).on "resize", @setModalBodyMaxHeight
    @el.on "click", ".modal-close", => @destroy(true)
    @el.on "hide", (e)=> false unless @isDestroyable
    
  setModalBodyMaxHeight: =>
    height = $(window).height() - @el.outerHeight() - ($(window).height()/100*20) + @el.find(".modal-body").height()
    height = 10 if height < 10
    @el.find(".modal-body").css "max-height", height

  destroy: (removeBackdrop)=>
    if @isDestroyable
      @el.remove()
      $(window).off "resize", @setModalBodyMaxHeight
      $(".modal-backdrop").remove() if removeBackdrop? and removeBackdrop

  shown: =>
    @el.addClass "ui-shown"
    @el.find("[autofocus=autofocus]").focus().select()
    do @setModalBodyMaxHeight    

  destroyable: => 
    @isDestroyable = true
    return @

  undestroyable: => 
    @isDestroyable = false
    return @

  @destroyAll: (removeBackdrop)=> 
    modal.destroy(removeBackdrop) for modal in App.Modal.all