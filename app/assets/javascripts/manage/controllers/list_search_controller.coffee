class window.App.ListSearchController extends Spine.Controller

  events:
    "change": "search"
    "preChange": "search"

  constructor: ->
    super
    @el.preChange()

  search: => 
    do @reset unless @currentSearch == @term()
    @currentSearch = @term()

  term: => if @el.val().length then @el.val() else null
