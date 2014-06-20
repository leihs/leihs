###
  
  Field is needed to edit/insert data of an item to the system

###

class window.App.Field extends Spine.Model

  @configure "Field", "id", "attribute", "default", "display_attr", "display_attr_ext", "forPackage",
                      "extended_key", "extensible", "form_name", "group", "label",
                      "permissions", "required", "search_attr", "search_path", "type", "value_attr",
                      "value_label", "value_label_ext", "values", "visibility_dependency_field_id", "visibility_dependency_value"
  
  @extend Spine.Model.Ajax

  @url = => "/manage/#{App.InventoryPool.current.id}/fields"

  constructor: ->
    super

  getLabel: ->  _jed(@label)

  isEditable: (item)->
    editable = true
    if @permissions? and item?
      editable = false if @permissions.role? and not App.AccessRight.atLeastRole(App.User.current.role, @permissions.role)
      editable = false if @permissions.owner? and @permissions.owner and item.owner? and App.InventoryPool.current.id != item.owner.id
    editable

  getValue: (item, attribute, defaultFallback)->
    if item?
      value =
        if attribute instanceof Array
          _.reduce attribute, (hash, attr) -> 
            if hash? and hash[attr]?
              hash[attr]
            else
              null
          , item
        else
          item[attribute]

    # some special behavior for retired ;(
    value = !! value if attribute == "retired"

    if value?
      value = @getFormatValueFunction()(value) if @format?
      return value
    else if @default? and defaultFallback
      @default
    else
      null

  getItemValueLabel: (value_label, item)=>
    if item?
      # local helper function
      reduceHelper = (valueLabel) ->
        if valueLabel instanceof Array
          _.reduce valueLabel, (hash, attr) -> 
            if hash? and hash[attr]?
              hash[attr]
            else 
              null
          , item
        else
          item[valueLabel]

      result = reduceHelper(value_label)

      # append extended value label if present
      result = [result, value_label_ext].join(" ") if value_label_ext = reduceHelper(@value_label_ext)

      result

  getFormatValueFunction: =>
    # returns a function object depending on the format properties
    if @format[0] == "decimal"
      Tools.formatNumber {padRight: @format[1]}
    else
      _.identity

  getFormName: (attribute = @attribute, formName = @form_name, asArray = null) ->
    if formName?
      "item[#{formName}]"
    else if attribute instanceof Array
      formName = _.reduce attribute, (name, attr) -> 
        "#{name}[#{attr}]"
      , "item"
      formName += "[]" if asArray?
      formName
    else
      "item[#{attribute}]"

  getExtendedKeyFormName: -> @getFormName @extended_key, @form_name

  children: ->
    _.filter App.Field.all(), (field)=> field.visibility_dependency_field_id == @id

  parent: ->
    if @visibility_dependency_field_id?
      App.Field.find @visibility_dependency_field_id

  getValueLabel: (values, value)-> 
    value = null if value == undefined
    value = _.find(values, (v) -> String(v.value) == value or v.value == value)
    if value
      value.label
    else
      ""

  @getValue: (target)->
    field = App.Field.find target.data("id")
    if target.find("[data-value]").length
      target.find("[data-value]").attr "data-value"
    else
      switch field.type
        when "radio"
          target.find("input:checked").val()
        when "date"
          target.find("input[type=hidden]").val()
        when "autocomplete"
          target.find("input[type=hidden]").val()
        when "autocomplete-search"
          target.find("input[type=hidden]").val()
        when "text"
          target.find("input[type=text]").val()
        when "textarea"
          target.find("textarea").val()
        when "select"
          target.find("option:selected").val()

  @validate: (form)=>
    valid = true
    form.find(".error").removeClass("error")
    for requiredField in form.find("[data-required='true'][data-editable='true']:visible")
      value = App.Field.getValue $ requiredField
      if not value? or value.length == 0
        valid = false 
        $(requiredField).addClass("error")
    return valid

  @toggleChildren: (target, form, options, forPackage)->
    field = App.Field.find target.data("id")
    form = $(form)
    children = field.children() if field.children?
    if children? and children.length
      for child in children
        if App.Field.getValue(target) == child.visibility_dependency_value or _.contains child.visibility_dependency_value, App.Field.getValue(target)
          unless App.Field.isPresent child, form
            if (forPackage and child.forPackage) or not forPackage
              target.after App.Render "manage/views/items/field", {}, $.extend(options, {field: child})
        else
          form.find("[name='#{child.getFormName()}']").closest("[data-type='field']").remove()

  @isPresent: (field, form)-> !! $(form).find("[data-id='#{field.id}']").length

  @grouped: (fields)-> _.groupBy fields, (field)-> if (field.group == null) then "" else field.group
