class window.App.ModelsIndexIpSelectorController extends Spine.Controller

  @activeInventoryPoolIds = []

  events:
    "change input[type='checkbox']": "changeInventoryPools"
    "click .dropdown-item": "selectInventoryPool"

  elements:
    ".button": "button"

  constructor: ->
    super
    App.ModelsIndexIpSelectorController.activeInventoryPoolIds = _.map @el.find("input:checked"), (i)-> $(i).closest("[data-id]").data().id

  selectInventoryPool: (e)=>
    target = $(e.target)
    if target.data("all")?
      @el.find("input:checkbox").prop("checked", true)
      do @changeInventoryPools
    else if target.hasClass "dropdown-item"
      @el.find("input:checkbox").prop("checked", false)
      target.find("input:checkbox").prop("checked", true).change()

  changeInventoryPools: (e)=>
    unless @el.find("input:checkbox:checked").length
      $(e.currentTarget).prop "checked", true
    else
      do @change

  change: =>
    App.ModelsIndexIpSelectorController.activeInventoryPoolIds = do @activeInventoryPoolIds
    do @render
    do @onChange

  activeInventoryPoolIds: => _.map @el.find("input:checked"), (i)-> $(i).closest("[data-id]").data("id")

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
        "#{length} #{_jed(length, "Inventory pool", "Inventory pools")}"
    @button.html App.Render "borrow/views/models/index/ip_selector", {text: text}

  reset: =>
    @el.find("input:checkbox").prop("checked", true)
    @render()

  is_resetable: => @activeInventoryPoolIds().length != @el.find("[data-id]").length
