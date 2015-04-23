###

  Selected Lines
 
  This script sets up functionalities for selection based functionalities for multiple reservations.
  
###

class window.App.LineSelectionController extends Spine.Controller

  @selected = []
  @Singleton = null

  elements:
    "#line-selection-counter": "lineSelectionCounter"

  constructor: ->
    super
    do @delegateEvents
    App.LineSelectionController.Singleton = @

  delegateEvents: =>
    @el.on "change", "input[data-select-line]", @toggleLine
    @el.on "change", "input[data-select-lines]", @toggleContainer
    @el.on "change", "input[data-select-lines], input[data-select-line]", @update
    @el.on "mouseenter", "input[data-select-lines]", @focusLines
    @el.on "mouseleave", "input[data-select-lines]", @blurLines
    App.Reservation.on "destroy", @update
    App.Contract.on "refresh", @update

  toggleLine: (e)=>
    line = $(e.currentTarget).closest ".line"
    @toggleContainerAbove line

  toggleContainer: (e)=>
    container = $(e.currentTarget).closest "[data-selected-lines-container]"
    @toggleLinesIn container

  toggleLinesIn: (container)=>
    checked = container.find("[data-select-lines]").is(":checked")
    for input in container.find("[data-select-line]")
      $(input).prop "checked", checked

  toggleContainerAbove: (line)=>
    container = line.closest "[data-selected-lines-container]"
    if container.find("[data-select-line]:not(:checked)").length
      container.find("[data-select-lines]").prop "checked", false
    else
      container.find("[data-select-lines]").prop "checked", true

  focusLines: (e)=> $(e.currentTarget).closest(".emboss").addClass("focus-thin")

  blurLines: (e)=> $(e.currentTarget).closest(".emboss").removeClass("focus-thin")

  update: =>
    reservations = $("[data-select-line]:checked").closest ".line"
    @store reservations
    @markVisitLinesController?.update App.LineSelectionController.selected
    @lineSelectionCounter.html reservations.length
    if reservations.length then @enable() else @disable()
    do @storeIds

  store: (reservations)->
    ids = _.flatten _.map reservations, (line) -> ($(line).data("ids") ? [$(line).data("id")])
    App.LineSelectionController.selected = ids

  restore: =>
    for input in $("[data-select-line]")
      input = $ input
      line = input.closest(".line")
      ids = $(line).data("ids") ? [$(line).data("id")]
      if ids.length and _.all(ids , (id)-> _.include(App.LineSelectionController.selected, id))
        input.prop("checked", true)
        @toggleContainerAbove line
    ids = App.LineSelectionController.selected
    @markVisitLinesController?.update App.LineSelectionController.selected
    @lineSelectionCounter.html ids.length
    if ids.length then @enable() else @disable()
    do @storeIds

  enable: =>
    for button in $(".button[data-selection-enabled]")
      App.Button.enable $(button)

  disable: =>
    for button in $(".button[data-selection-enabled]")
      App.Button.disable $(button)

  storeIds: =>
    do @storeIdsToHrefs
    do @storeIdsToInputValues

  storeIdsToHrefs: =>
    for link in $("a[data-update-href]")
      link = $ link
      uri = URI(link.attr("href")).removeQuery("ids[]").addQuery("ids[]", App.LineSelectionController.selected)
      link.attr "href", uri.toString()

  storeIdsToInputValues: =>
    @el.find("[data-input-fields-container]").remove()
    @el.find("[data-insert-before]").before("<div data-input-fields-container></div>")
    appendTo = @el.find("[data-input-fields-container]")
    for id in App.LineSelectionController.selected
      appendTo.append "<input type='hidden' name='ids[]' data-store-id value='#{id}'>"

  @add: (id)=>
    unless _.find(@selected, (i)-> i is id)
      @selected.push id
      do @Singleton.restore
