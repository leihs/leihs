class window.App.Borrow.StartController extends Spine.Controller

  elements:
    "[data-category_id]": "rootCategoryElements"

  events:
    "mouseenter [data-category_id]:not(.fetched)": "fetchChildren"

  fetchChildren: (e)->
    category_el = $(e.currentTarget)
    category_el.addClass "fetched"
    category = App.Category.find_or_build
      id: category_el.data "category_id"
    App.Category.ajaxFetch
      data: $.param
        category_id: category.id
    .done (children)=>
        @render category, children

  render: (parent, children) =>
    parent_el = $ _.find @rootCategoryElements, (el) -> parseInt(el.getAttribute("data-category_id")) == parent.id
    if children.length
      data = _(_.map(children, (c)->{text: c.name, link: "/borrow/models?category_id=#{c.id}"})).sortBy("text")
      parent_el.find(".dropdown").html App.Render "views/dropdown/dropdown-item", data
