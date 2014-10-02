class window.App.GroupPartitionsController extends Spine.Controller

  elements:
    "input[data-search-models]": "input"
    "[data-models-list]": "modelsList"

  events:
    "preChange input[data-search-models]": "search"
    "click [data-remove-group]": "removeHandler"

  constructor: ->
    super
    @input.preChange()

  search: =>
    return false unless @input.val().length
    @fetchModels().done (data) =>
      @setupAutocomplete(App.Model.find datum.id for datum in data)

  fetchModels: =>
    App.Model.ajaxFetch
      data: $.param
        search_term: @input.val()
        borrowable: true
        per_page: 5

  setupAutocomplete: (models) =>
    @input.autocomplete
      source: (request, response) => response models
      focus: => return false
      select: @select
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "manage/views/groups/partitions/autocomplete_element", item).data("value", item).appendTo(ul)
    @input.autocomplete("search")

  select: (e, ui) =>
    App.Availability.ajaxFetch
      url: App.Availability.url()+"/in_stock"
      data: $.param
        model_ids: ui.item.id
    .done (data) =>
      modelElement = @modelsList.find("input[name='group[partitions_attributes][][model_id]'][value='#{ui.item.id}']").closest(".line")
      if modelElement.length
        @modelsList.prepend modelElement
      else
        @modelsList.prepend(App.Render "manage/views/groups/partitions/model_allocation_entry", App.Model.find(ui.item.id), currentInventoryPool: App.InventoryPool.current)
