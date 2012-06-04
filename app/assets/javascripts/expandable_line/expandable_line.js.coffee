###

  Expandable Line

  This script provides functionalities for a expandable line
  
###

$ = jQuery

$.extend $.fn, expandable_line: (options)-> @each -> $(this).data('_expandable_line', new ExpandableLine(this, options)) unless $(this).data("_expandable_line")?

class ExpandableLine
  
  @element
  
  constructor:(element, options)->
    @element = $(element)
    @target = $(@element.data("toggle_target"))
    do @delegateEvents
    this
    
  delegateEvents: =>
    @element.on "click", (e)=> if $(e.currentTarget).hasClass("open") then do @collapse else do @expand 
  
  collapse: =>
    @element.removeClass("open")
    @element.find("*[data-open_title]").each (i,el)-> $(el).attr "title", $(el).data("closed_title") 
    @target.hide()
    
  expand: =>
    @element.addClass("open")
    @element.find("*[data-open_title]").each (i,el)->
      $(el).data "closed_title", $(el).attr("title")
      $(el).attr "title", $(el).data("open_title") 
    @target.show()
