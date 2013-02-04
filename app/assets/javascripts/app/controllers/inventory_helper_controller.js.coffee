class InventoryHelperController

  el: "#inventory_helper"
  
  constructor: (fields)->
    @el = $(@el)
    @fields = _.map fields, (field)-> new App.Field field
    @fieldSelection = @el.find("#field_selection form")
    @fieldSelectionInput = @el.find("#field_selection input#fieldname")
    @itemSelection = @el.find("#item_selection")
    @itemView = @el.find("#item")
    @notifications_el = @itemView.find(".notifications")
    @inventoryCode = @itemSelection.find("input[name='inventory_code']")
    @itemSelection.find("button").removeAttr("disabled")
    @editButton = @itemView.find(".edit.button")
    @cancelEditButton = @itemView.find(".cancel.button")
    @saveEditedButton = @itemView.find(".save.button")
    do @setupFieldSelection
    do @delegateEvents

  setupFieldSelection: ->
    @fieldSelectionInput.autocomplete
      source: (request, response)=> 
        fields = _.filter @fields, (field)=> 
          field.label.match(new RegExp(request.term,"i"))? and
          not App.Field.isPresent(field, @fieldSelection) and
          not field.visibility_dependency_field_id? and
          not field.readonly
        response _.map (_.sortBy fields, (field)-> field.label), (field)-> {label: field.label, value: field.value, field: field}
      select: (event, ui)=>
        @addField ui.item.field
        @fieldSelectionInput.val("")
        return false
      minLength: 0
    @fieldSelectionInput.bind "focus, click", -> $(@).autocomplete "search"
    @fieldSelectionInput.autocomplete("widget").addClass "inventory_helper_field_selection"

  delegateEvents: ->
    @fieldSelection.on "change", "input[name], textarea, select", (e)=> App.Field.toggleChildren $(e.currentTarget).closest(".field"), @fieldSelection
    @fieldSelection.on "submit", (e)=>
      e.preventDefault()  
      return false
    @itemSelection.on "submit", (e)=> 
      e.preventDefault()  
      @applyFields(@inventoryCode.val())
      return false
    @editButton.on "click", @switchToEditMode
    @cancelEditButton.on "click", @cancelEditMode
    @saveEditedButton.on "click", @saveEditedItem
    @inventoryCode.on "autocomplete:select", (event,element)=>
      @inventoryCode.val element.item.value
      @itemSelection.submit()
      @inventoryCode.blur()
      return false
    @fieldSelection.on "click", ".field .removable", -> $(this).closest(".field").remove() 

  addField: (field)->
    return true if App.Field.isPresent field, @fieldSelection
    @fieldSelection.find("h2").remove() unless @fieldSelection.find(".field").length
    target = if @fieldSelection.find(".left .field").length <= @fieldSelection.find(".right .field").length
      @fieldSelection.find(".left")
    else
      @fieldSelection.find(".right")
    target.append $.tmpl "app/views/inventory/edit/field", field, {removable: true}
    target.show()

  applyFields: (inventoryCode)->
    do @resetItemView
    do @resetNotifications
    inventoryCode = _.str.trim inventoryCode
    if not inventoryCode? or inventoryCode.length == 0
      Notification.add_headline
        title: _jed('Error')
        text: _jed('Please provide an Inventorycode')
        type: "error"
      return false
    else
      if App.Field.validate @fieldSelection
        @updateItem inventoryCode, @fieldSelection.serializeArray(), @fieldSelection.find(".field")
      else
        Notification.add_headline
          title: _jed('Error')
          text: _jed('Please provide all required fields')
          type: "error"
        return false
  
  updateItem: (inventoryCode, data, fields)->
    @itemView.removeClass "error"
    if data.length
      $.ajax
        url: "/backend/inventory_pools/#{currentInventoryPool.id}/items?inventory_code=#{inventoryCode}"
        data: data
        datatype: "text"
        type: "PUT"
        success: (item)=> 
           @renderItem item
           @highlightChangedFields fields
        error: (xhr) => 
          if xhr.responseText.length and xhr.responseText != "{}"
            @addError xhr.responseText
          @getUpdatedItem @inventoryCode.val(), fields
    else
      @getUpdatedItem @inventoryCode.val(), fields

  addError: (error)-> 
    @notifications_el.append "<div class='notification error'>#{error}</div>"
    @itemView.addClass "error"

  getUpdatedItem: (inventoryCode, fields)->
    $.ajax
      url: "/backend/inventory_pools/#{currentInventoryPool.id}/items/find?inventory_code=#{inventoryCode}"
      error: => @addError _jed("The item with the inventory code '%s' was not found", inventoryCode)
      success: (item)=>
        $.ajax
          url: "/backend/inventory_pools/#{currentInventoryPool.id}/items/#{item.id}"
          data: 
            with:
              preset: "item_edit"
          success: (item) => 
            @renderItem item
            @highlightChangedFields fields
          error: =>
            Notification.add_headline
              title: _jed('Error')
              text: _jed("You don't have permission")
              type: "error"

  renderItem: (item)=>
    @currentItem = item
    new App.EditItemController @fields, item
    @itemView.addClass "selected"
    $(document).scrollTop @itemView.offset().top

  resetItemView: -> @itemView.find(".left, .right").html ""
  
  resetNotifications: -> @notifications_el.html ""

  highlightChangedFields: (fields)->
    for field in fields
      field = $(field).tmplItem().data
      @itemView.find(".field[data-field_id='#{field.id}']").addClass "highlight"

  switchToEditMode: =>
    @itemView.addClass "edit"
    @itemSelection.find("input, .button").attr("disabled", true)

  cancelEditMode: =>
    @itemView.removeClass "edit"
    @itemSelection.find("input, .button").removeAttr("disabled")

  saveEditedItem: =>
    @itemView.removeClass "edit"
    @itemSelection.find("input, .button").removeAttr("disabled")
    @updateItem @inventoryCode.val(), @itemView.find("form").serializeArray(), []
    do @resetItemView

window.App.InventoryHelperController = InventoryHelperController