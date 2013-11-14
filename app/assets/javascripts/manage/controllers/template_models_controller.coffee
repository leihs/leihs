class window.App.TemplateModelsController extends Spine.Controller

  elements:
    "input[data-search-models]": "input"
    "[data-models-list]": "modelsList"

  events:
    "delayedChange input[data-search-models]": "search"

  constructor: ->
    super
    @input.delayedChange()

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
      $(App.Render "manage/views/templates/models/autocomplete_element", item).data("value", item).appendTo(ul)
    @input.autocomplete("search")

  select: (e, ui) =>
    App.Availability.ajaxFetch
      url: App.Availability.url()+"/in_stock"
      data: $.param
        model_ids: ui.item.id
    .done (data) =>
      @modelsList.prepend(App.Render "manage/views/templates/models/model_allocation_entry", App.Model.find(ui.item.id), currentInventoryPool: App.InventoryPool.current) unless _.any @modelsList.find("input[name*='model_id']"), (i) -> Number($(i).val()) == Number(ui.item.id)
