class window.App.Borrow.ModelsIndexSearchController extends Spine.Controller

  events:
    "delayedChange input": "onChange"

  elements:
    "input": "inputField"

  constructor: ->
    super
    @inputField.delayedChange()

  getInputText: ->
    if @inputField.val().length
      {search_term: @inputField.val()}
    else
      {search_term: null}

  reset: =>
    @inputField.val ""

  is_resetable: => @getInputText().searchTerm? and @getInputText().searchTerm.length > 0
