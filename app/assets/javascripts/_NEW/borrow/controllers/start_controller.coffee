class window.App.Borrow.StartController extends Spine.Controller

  elements:
    "[data-category_id]": "rootCategoryElements"

  events:
    "mouseenter [data-category_id]:not(.fetched)": "fetchChildren"

  delegateEvents: ->
    super
    App.Category.bind "refresh", @renderCategories
    App.CategoryLink.bind "refresh", @renderCategoryLinks

  fetchChildren: (e)->
    category_el = $(e.currentTarget)
    category_el.addClass "fetched"
    category = App.Category.find_or_build
      id: category_el.data "category_id"
    App.CategoryLink.fetch
      data: $.param
        ancestor_id: category.id
    App.Category.fetch
      data: $.param
        category_id: category.id
        children: true

  renderCategories: (categories)=>
    if not _.isEmpty(categories)
      @render _.first(_.first(categories).parents())

  renderCategoryLinks: (links)=>
    if not _.isEmpty(links)
      @render _.first(links).ascendant()

  render: (parent) =>
    parent_el = $ _.find @rootCategoryElements, (el) -> parseInt(el.getAttribute("data-category_id")) == parent.id
    data = _(_.map(parent.children(), (c)->{text: c.name, link: "/borrow/models?category_id=#{c.id}"})).sortBy("text")
    parent_el.find(".dropdown").html App.Render "dropdown/dropdown-item", data
