class window.App.CategoryController

  constructor: (options)->
    @currentCategoryId = options.currentCategoryId
    do @removeCategoryItself
    do @delegateEvents

  delegateEvents: ->
    $(".simple_tree input[type='checkbox']").on "change", @changeCategoryLink
    $(document).on "keyup change", "input[name='category[name]']", @changeCurrentCategoryName
    $(document).on "keyup change", ".simple_tree input[name='label']", @changeLabel

  removeCategoryItself: -> # we have an acyclic graph no cycles !
    for currentCategory in $(".simple_tree input[type='checkbox'][value='#{@currentCategoryId}']")
      unless $(currentCategory).is(":disabled")
        $(currentCategory).closest("li").remove()

  changeCategoryLink: ->
    target = $(this)
    sameCategories = $(".simple_tree input[type='checkbox'][value='#{target.val()}']")
    sameCategories.attr 'checked', target.is(":checked")
    if target.is(":checked")
      for treeElement in sameCategories
        listElement = $(treeElement).closest("li")
        template = $.tmpl "app/views/categories/tree_element", {parent_id: target.val(), name: $("input[name='category[name]']").val()}
        $(listElement).append("<ul class='simple_tree'></ul>") unless listElement.children("ul").length
        $(listElement).children("ul").prepend template
    else
      for treeElement in sameCategories
        listElement = $(treeElement).closest("li")
        $(listElement).children("ul").children("li.current_category").remove()
  
  changeCurrentCategoryName: ->
    $("li.current_category .name").html $(this).val()

  changeLabel: ->
    changedLink = $(this).closest(".model_group_link")
    sameLinks = $(".model_group_link[data-parent_id='#{changedLink.data("parent_id")}']")
    for sameLink in sameLinks
      $(sameLink).find("input[name='label']").val $(this).val()
