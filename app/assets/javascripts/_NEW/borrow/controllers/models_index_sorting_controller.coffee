class window.App.Borrow.ModelsIndexSortingController extends Spine.Controller

  events:
    "click a[data-sort]": "change"

  elements:
    ".button": "button"

  change: (e)=> 
    target = $(e.currentTarget)
    dropdown = target.closest ".dropdown"
    dropdown.addClass("hidden")
    _.delay (=> dropdown.removeClass("hidden")), 200
    @sort = target.data "sort"
    @order = target.data "order"
    do @render
    do @onChange

  render: (e)=>
    @button.html App.Render "borrow/views/models/index/sorting", {sort: @sort, order: @order}

  getCurrentSorting: => {sort: @sort, order: @order}