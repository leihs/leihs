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
      {searchTerm: @inputField.val()}
    else
      {searchTerm: null}

  reset: =>
    @inputField.val ""

  is_resetable: => @getInputText().searchTerm? and @getInputText().searchTerm.length > 0