class window.App.CategoryController extends Spine.Controller

  elements:
    "input[name='category[name]']": "nameInput"

  constructor: ->
    super
    @currentCategoryId = @nameInput.data("id")
    do @removeCategoryItself
    do @delegateEvents

  delegateEvents: =>
    $(".simple_tree input[type='checkbox']").on "change", @changeCategoryLink
    $(document).on "keyup change", "input[name='category[name]']", @changeCurrentCategoryName
    $(document).on "keyup change", ".simple_tree input[name='label']", @changeLabel
    #$(".simple_tree input[type='checkbox']").on "change", @changeCategoryLink
    #@nameInput.on "keyup change", @changeCurrentCategoryName
    #@el.on "keyup change", ".simple_tree input[name='label']", @changeLabel

  removeCategoryItself: -> # we have an acyclic graph no cycles !
    for currentCategory in $(".simple_tree input[type='checkbox'][value='#{@currentCategoryId}']")
      unless $(currentCategory).is(":disabled")
        $(currentCategory).closest("li").remove()

  changeCategoryLink: => console.log "change category link"

  @changeCurrentCategoryName: => 
    debugger
    console.log "change current category name"

  @changeLabel: => 
    debugger
    console.log "change label"
