class window.App.ModelsIndexSearchController extends Spine.Controller

  events:
    "preChange input": "onChange"

  elements:
    "input": "inputField"

  constructor: ->
    super
    @inputField.preChange()

  getInputText: ->
    if @inputField.val().length
      {search_term: @inputField.val()}
    else
      {search_term: null}

  reset: =>
    @inputField.val ""

  is_resetable: => @getInputText().search_term? and @getInputText().search_term.length > 0
