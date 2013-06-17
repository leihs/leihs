class window.App.Borrow.ModelsIndexIpSelectorController extends Spine.Controller

  events:
    "change input[type='checkbox']": "changeInventoryPools"
    "click .dropdown-item": "selectInventoryPool"

  elements:
    ".button": "button"

  selectInventoryPool: (e)=>
    target = $(e.target)
    if target.hasClass "dropdown-item"
      @el.find("input[type='checkbox']").attr("checked", false)
      target.find("input[type='checkbox']").attr("checked", true).change()
      dropdown = target.closest(".dropdown")
      dropdown.addClass("hidden")
      _.delay (=> dropdown.removeClass("hidden")), 200

  changeInventoryPools: (e)=>
    unless @el.find("input[type='checkbox']:checked").length
      $(e.currentTarget).attr "checked", true
    else
      do @change

  change: =>
    do @render
    do @onChange

  activeInventoryPoolIds: =>
    _.map @el.find("input:checked"), (i)-> $(i).closest("[data-id]").data("id")

  render: =>
    activeInventoryPools = _.map @el.find("input:checked"), (i)-> $(i).closest("[data-id]").data()
    total_count = @el.find("input").length
    length = activeInventoryPools.length
    text = switch length
      when 1
        _.first(activeInventoryPools).name
      when total_count
        _jed("All inventory pools")
      else
        "#{length} #{_jed(length, _jed("Inventory pool"), _jed("Inventory pools"))}"
    @button.html App.Render "borrow/views/models/index/ip_selector", {text: text}