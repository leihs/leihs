###
  
  Field is needed to edit/insert data of an item to the system

###

class Field

  @fields = []

  constructor: (data, item)->
    for k,v of data
      @[k] = v
    @formName = @getFormName @attribute, @form_name
    @label = _jed(@label)
    if item?
      @value = @getValue item, @attribute
      @value = @default if !@value? and @default?
      @editable = @getEditable item
      @item = item
    else
      @editable = true
      @value = @default if !@value? and @default?
    Field.fields[@id] = @
    @

  getEditable: (item)->
    editable = true
    editable = false if @readonly? and @readonly
    if @permissions?
      editable = false if @permissions.level? and current_user.access_level < @permissions.level
      editable = false if @permissions.owner? and @permissions.owner and item.owner? and currentInventoryPool.id != item.owner.id
    editable

  getValue: (item, attribute)->
    if attribute instanceof Array
      _.reduce attribute, (hash, attr) -> 
        if hash? and hash[attr]?
          hash[attr]
        else 
          null
      , item
    else
      item[attribute]

  getValueLabel: (value_label, item)=>
    if value_label instanceof Array
      _.reduce value_label, (hash, attr) -> 
        if hash? and hash[attr]?
          hash[attr]
        else 
          null
      , item
    else
      item[value_label]

  getFormName: (attribute, formName)->
    if formName?
      "item[#{formName}]"
    else if attribute instanceof Array
      _.reduce attribute, (name, attr) -> 
        "#{name}[#{attr}]"
      , "item"
    else
      "item[#{attribute}]"

  children: ->
    _.filter Field.all(), (field)=> field.visibility_dependency_field_id == @id

  parent: ->
    if @visibility_dependency_field_id?
      Field.find @visibility_dependency_field_id

  @all: ->
    fields = []
    for id, field of @fields
      fields.push field
    fields

  @find: (id)-> @fields[id]

  @getValue: (field_el)->
    field_el = $(field_el)
    if field_el.is ".radio"
      $(field_el).find("input:checked").val()
    else if field_el.is ".checkbox"
      $(field_el).find("input:checked").val()
    else if field_el.is ".date"
      $(field_el).find("input[type=hidden]").val()
    else if field_el.is ".autocomplete"
      $(field_el).find("input[type=hidden]").val()
    else if field_el.is ".autocomplete-search"
      $(field_el).find("input[type=hidden]").val()
    else if field_el.is ".text"
      $(field_el).find("input[type=text]").val()
    else if field_el.is ".textarea"
      $(field_el).find("textarea").val()
    else if field_el.is ".select"
      $(field_el).find("option:selected").val()

  @getLabel: (values, value)-> 
    value = null if value == undefined
    value = _.find(values, (v) -> String(v.value) == value or v.value == value)
    if value
      value.label
    else
      ""

  @validate: (form)=>
    valid = true
    form.find(".invalid").removeClass("invalid")
    for mandatory_field in form.find(".field.required:visible.editable")
      field_value = App.Field.getValue(mandatory_field)
      if not field_value? or field_value.length == 0
        valid = false 
        $(mandatory_field).addClass("invalid")
    return valid

  @toggleChildren: (field_el, form)->
    field_el = $(field_el)
    field = field_el.tmplItem().data
    form = $(form)
    children = field.children() if field.children?
    if children? and children.length
      for child in children
        if App.Field.getValue(field_el) == child.visibility_dependency_value
          unless App.Field.isPresent child, form
            $(field_el).after $.tmpl "app/views/inventory/edit/field", child
        else
          form.find("[name='#{child.formName}']").closest(".field").remove()

  @isPresent: (field, form)-> !! $(form).find("[name='#{field.formName}']").length

  @grouped: (fields)-> _.groupBy fields, (field)-> if (field.group == null) then "" else field.group

window.App.Field = Field
