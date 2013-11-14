class window.App.ListSearchController extends Spine.Controller

  events:
    "change": "search"
    "delayedChange": "search"

  constructor: ->
    super
    @el.delayedChange()

  search: => 
    do @reset unless @currentSearch == @term()
    @currentSearch = @term()

  term: => if @el.val().length then @el.val() else null
