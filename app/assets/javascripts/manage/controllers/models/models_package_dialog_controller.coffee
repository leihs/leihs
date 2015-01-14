class window.App.ModelsPackageDialogController extends Spine.Controller

  elements:
    "#notifications": "notifications"
    "#item-form": "itemForm"
    "#search-item": "searchItemInput"
    "#items": "childrenContainer"

  events:
    "focus #search-item": "setupAutocomplete"
    "inline-entry-remove [data-type='inline-entry']": "removeItem"
    "click #save-package": "save"

  constructor: ->
    @el = $ App.Render "manage/views/models/packages/package_dialog"
    super
    @searchItemInput.preChange()
    @childrenContainer.html App.Render "manage/views/models/packages/item", @children
    @modal = new App.Modal @el
    new App.InlineEntryRemoveController {el: @el}
    do @setupFlexibleFields

  setupFlexibleFields: =>
    @flexibleFieldsController = new App.ItemFlexibleFieldsController
      el: @itemForm.find("#flexible-fields")
      itemData: @item
      itemType: "item"
      forPackage: true
      writeable: true

  setupAutocomplete: (e)=>
    input = $ e.currentTarget
    input.autocomplete
      source: (request, response) => 
        response []
        @fetchItems(request.term).done (data)=> 
          items = (App.Item.find datum.id for datum in data)
          @fetchModels(items).done => 
            response items if input.is(":focus")
      focus: => return false
      select: (e, ui) => @select(e, ui) and input.val("") and input.blur()
      appendTo: @modal.el
      minLength: 1
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "manage/views/models/packages/item_autocomplete_element", item).data("value", item).appendTo(ul)
    input.autocomplete("search")

  fetchItems: (searchTerm)=>
    App.Item.ajaxFetch
      data: $.param
        search_term: searchTerm
        not_packaged: true
        packages: false
        retired: false

  fetchModels: (items)=>
    ids = _.uniq _.map items, (i)->i.model_id
    return {done: (c)->c()} unless ids.length
    App.Model.ajaxFetch
      data: $.param
        ids: ids
        paginate: false

  select: (e,ui)=>
    @addItem ui.item

  addItem: (item)=>
    return true if _.find(@children, (i)->i.id == item.id)
    @children.push item
    @modal.el.find("#items").append App.Render "manage/views/models/packages/item", item

  removeItem: (e)=>
    entry = $(e.currentTarget).closest("[data-type='inline-entry']")
    @children = _.filter @children, (i) -> i.id != entry.data("id")

  save: =>
    @notifications.addClass("hidden").html ""
    unless @children.length
      @notifications.removeClass("hidden").html App.Render "manage/views/models/packages/no_items_error"
    else if not App.Field.validate @itemForm
      @notifications.removeClass("hidden").html App.Render "manage/views/models/packages/missing_data_error"
    else
      @modal.destroy true
      data = _.map @itemForm.serializeArray(), (datum)->
        name: datum.name.replace(/item/, "")
        value: datum.value
      @done data, @children, @entry
