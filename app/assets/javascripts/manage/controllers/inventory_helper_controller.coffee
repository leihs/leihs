class App.InventoryHelperController extends Spine.Controller
  
  elements:
    "#field-selection": "fieldSelection"
    "#field-input": "fieldInput"
    "#item-selection": "itemSelection"
    "#flexible-fields": "flexibleFields"
    "#item-section": "itemSection"
    "#item-input": "itemInput"
    "#item-edit": "editButton"
    "#save-edit": "saveButton"
    "#cancel-edit": "cancelButton"
    "#notifications": "notifications"
    "#no-fields-message": "noFieldsMessage"
    "#field-form-left-side": "formLeftSide"
    "#field-form-right-side": "formRightSide"

  events:
    "focus #field-input": "setupFieldAutocomplete"
    "click [data-type='remove-field']": "removeField"
    "change #field-selection [data-type='field']": "toggleChildren"
    "submit #item-selection": "applyFields"
    "click #item-edit": "editItem"
    "click #cancel-edit": "cancelEdit"
    "click #save-edit": "saveItem"
    "change #field-selection input[name='item[owner][id]']": "showOwnerChangeNotification"

  constructor: ->
    super
    @fetchFields().done =>(do @setupFieldAutocomplete if @fieldInput.is ":focus")
    do @setupItemAutocomplete

  delegateEvents: =>
    super
    @el.on "submit", "form", (e)=> e.preventDefault()    
    
  fetchFields: =>
    App.Field.ajaxFetch()

  setupFieldAutocomplete: ->
    @fieldInput.autocomplete
      source: @getFields
      focus: => return false
      select: @selectField
      minLength: 0
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "views/autocomplete/element", item).data("value", item).appendTo(ul)
    @fieldInput.autocomplete("search")

  getFields: (request, response)=> 
    fields = _.filter App.Field.all(), (field)=> 
      field.getLabel().match(new RegExp(request.term,"i"))? and
      not App.Field.isPresent(field, @fieldSelection) and
      not field.visibility_dependency_field_id?
    response _.map (_.sortBy fields, (field)-> field.getLabel()), (field)-> {label: field.getLabel(), value: field.value, field: field}

  selectField: (e,ui) =>
    @addField ui.item.field
    @fieldInput.val("").autocomplete("destroy").blur()
    return false

  removeField: (e)=> 
    target = $(e.currentTarget).closest("[data-type='field']")
    field = App.Field.find target.data("id")
    for child in field.children()
      @fieldSelection.find("[name='#{child.getFormName()}']").closest("[data-type='field']").remove()
    target.remove()
    @noFieldsMessage.removeClass("hidden") unless @fieldSelection.find("[data-type='field']").length

  toggleChildren: (e)=> 
    App.Field.toggleChildren $(e.currentTarget).closest("[data-type='field']"), @fieldSelection, {writeable: true, removeable: true, fieldColor: "white"}

  setupItemAutocomplete: =>    
    @itemInput.autocomplete
      source: (request, response)=>
        @fetchItems(request.term).done (data)=> 
          items = (App.Item.find datum.id for datum in data)
          @fetchItemLocations(items).done => response items
      focus: => return false
      select: (e,ui)=>
        @itemInput.val ui.item.inventory_code
        do @applyFields
      minLength: 0
    .data("uiAutocomplete")._renderItem = (ul, item) => 
      $(App.Render "manage/views/inventory/helper/item_autocomplete_element", item).data("value", item).appendTo(ul)

  fetchItems: (term)=>
    App.Item.ajaxFetch
      data: $.param
        search_term: term

  fetchItemLocations: (items)=>
    ids = _.map items, (i)->i.id
    return {done: (c)->c()} unless ids.length
    App.CurrentItemLocation.ajaxFetch
      data: $.param
        ids: ids
        all: true
        paginate: false

  addField: (field)=>
    return true if App.Field.isPresent field, @fieldSelection
    @noFieldsMessage.addClass("hidden") unless @fieldSelection.find("[data-type='field']").length
    target = if @formLeftSide.find("[data-type='field']").length <= @formRightSide.find("[data-type='field']").length
      @formLeftSide
    else
      @formRightSide
    template = $(App.Render "manage/views/items/field", {}, {field: field, writeable: true, removeable: true, fieldColor: "white"})
    target.append template
    @toggleChildren {currentTarget: template}

  applyFields: =>
    do @resetNotifications
    inventoryCode = @itemInput.val()
    @itemInput.val("").blur()
    do App.Flash.reset
    unless inventoryCode.length
      App.Flash
        type: "error"
        message: _jed('Please provide an inventory code')
    else if not App.Field.validate @fieldSelection
      App.Flash
        type: "error"
        message: _jed('Please provide all required fields')
    else
      data = @fieldSelection.serializeArray()
      @fetchItem inventoryCode, (item)=> 

        @updateItem(item, data)
        .fail (e, status)=>
          @fetchItemWithFlexibleFields(item).done (itemData)=>
            @currentItemData = itemData
            @setupAppliedItem "error"
        .done (data)=> 
          @currentItemData = data
          @setupAppliedItem "success"

  setupAppliedItem: (status)=>
    @setupItemEdit false
    if @currentItemData.owner_id == App.InventoryPool.current.id or @currentItemData.inventory_pool_id == App.InventoryPool.current.id
      @editButton.removeClass("hidden")
      @saveButton.addClass("hidden")
      @cancelButton.addClass("hidden")
    @highlightChangedFields @fieldSelection.find(".field"), status
    $(document).scrollTop @itemSection.offset().top

  highlightChangedFields: (fields, status)=>
    for fieldEl in fields
      @flexibleFields.find(".field[data-id='#{$(fieldEl).data("id")}']").addClass status

  setupItemEdit: (writeable)=>
    if @flexibleFieldsController? # release old controller 
      replacement = @flexibleFields.clone(false)
      @flexibleFields.replaceWith replacement
      @flexibleFieldsController.release()
      @flexibleFields = replacement
    @flexibleFieldsController = new App.ItemFlexibleFieldsController
      el: @flexibleFields
      itemData: @currentItemData
      writeable: writeable
  
  fetchItem: (inventoryCode, callback)=>
    App.Item.ajaxFetch
      data: $.param
        inventory_code: inventoryCode
    .done (data)=>
      if data.length
        callback App.Item.find(data[0].id)
      else
        App.Flash
          type: "error"
          message: _jed "The Inventory Code %s was not found.", inventoryCode

  fetchItemWithFlexibleFields: (item)=>
    App.Item.ajax().find item.id,
      data: $.param
        for: "flexibleFields"

  updateItem: (item, data)=>
    unless data.length
      h = 
        always: (c)-> c()
        fail: (c)-> c()
        done: (c)-> c()
      return h
    else
      item.updateWithFieldData(data)
      .fail (e)=> @setNotification(e.responseText, "error")

  setNotification: (text, status)-> 
    @notifications.html App.Render "manage/views/inventory/helper/"+status, {text: text}

  resetNotifications: -> 
    @notifications.html ""
    do App.Flash.reset

  editItem: =>
    @editButton.addClass("hidden")
    @saveButton.removeClass("hidden")
    @cancelButton.removeClass("hidden")
    @setupItemEdit true
    do @resetNotifications
    if @currentItemData.owner_id != App.InventoryPool.current.id
      @setNotification "#{_jed("You are not the owner of this item")} #{_jed("therefore you may not be able to change some of these fields")}", "error"

  cancelEdit: =>
    @editButton.removeClass("hidden")
    @saveButton.addClass("hidden")
    @cancelButton.addClass("hidden")
    @setupItemEdit false
    do @resetNotifications
    do @resetNotifications

  saveItem: =>
    if @flexibleFieldsController.validate()
      item = App.Item.find @currentItemData.id
      @updateItem(item, @flexibleFields.serializeArray()).done => 
        @fetchItemWithFlexibleFields(item).done (itemData)=>
          @currentItemData = itemData
          do @setupSavedItem
      do @disableFlexibleFields

  setupSavedItem: =>
    @setupItemEdit false
    @editButton.removeClass("hidden")
    @saveButton.addClass("hidden")
    @cancelButton.addClass("hidden")
    do @resetNotifications
    @setNotification _jed("%s successfully saved", _jed("Item")), "success"

  disableFlexibleFields: =>
    @flexibleFields.find("input,textarea,select").attr "disabled", true

  showOwnerChangeNotification: =>
    App.Flash
      type: "notice"
      message: _jed("If you transfer an item to a different inventory pool it's not visible for you anymore.")