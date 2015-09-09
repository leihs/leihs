class window.App.ItemFlexibleFieldsController extends Spine.Controller

  events:
    "change input[name='item[owner][id]']": "showOwnerChangeNotification"
    "submit": "validate"
    "change [data-type='field']": "toggleChildren"

  constructor: ->
    super
    @fetchFields().done =>
      do @renderForm
      do @setupFields
      for field in @el.find("[data-type='field']")
        @toggleChildren {currentTarget: field}
      $("#show-all-fields").show() if $(".hidden.field").length

  fetchFields: =>
    return {done: (c)->c()} if App.Field.all().length
    App.Field.ajaxFetch
      data: $.param
        target_type: @itemType

  renderForm: => 
    @el.html App.Render "manage/views/items/form"
    @formLeftSide = @el.find "#item-form-left-side"
    @formRightSide = @el.find "#item-form-right-side"

  setupFields: =>
    fields = _.filter App.Field.all(), (f)-> not f.visibility_dependency_field_id?
    fields = _.filter(fields, (f)-> f.forPackage) if @forPackage
    for groupName, fields of App.Field.grouped fields
      template = $ App.Render "manage/views/items/group_of_fields", {name: groupName}
      group = template.find(".group-of-fields")
      for field in fields
        group.append App.Render "manage/views/items/field", {}, { field: field, itemData: @itemData, writeable: @writeable, hideable: @hideable }
      target = if @formLeftSide.find("[data-type='field']").length <= @formRightSide.find("[data-type='field']").length
        @formLeftSide
      else
        @formRightSide
      target.append template

  showOwnerChangeNotification: =>
    App.Flash
      type: "notice"
      message: _jed("If you transfer an item to a different inventory pool it's not visible for you anymore.")

  validate: (e)=>
    unless App.Field.validate @el
      App.Flash
        type: "error"
        message: _jed('Please provide all required fields')    
      do e.preventDefault if e?
      return false
    else
      true

  toggleChildren: (e)=>
    App.Field.toggleChildren $(e.currentTarget), @el, {itemData: @itemData, writeable: @writeable}, @forPackage
