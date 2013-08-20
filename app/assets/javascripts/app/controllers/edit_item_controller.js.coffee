class EditItemController

  el: "#item.form_edit"
  
  constructor: (fields, item)->
    @el = $(@el)
    @form = @el.find "form"
    fields = _.map fields, (field)-> new App.Field field, item
    @setupFields fields
    _.each @form.find(".field"), (field)=> App.Field.toggleChildren field, @form
    do @delegateEvents

  setupFields: (fields)->
    groupedFields = App.Field.grouped fields
    for group, fields of groupedFields
      groupedFields_el = $.tmpl "app/views/inventory/edit/field_group", {name: group, fields: fields}
      target = if @el.find(".left .field").length <= @el.find(".right .field").length
        @el.find(".left")
      else
        @el.find(".right")
      target.append groupedFields_el
    
  delegateEvents: ->
    @form.on "change", "input[name='item[owner][id]']", @changeOwnerNotification
    @form.on "submit", @validate
    @form.on "change", "input[name], textarea, select", (e)=> App.Field.toggleChildren $(e.currentTarget).closest(".field"), @form

  changeOwnerNotification: ->
    Notification.add_headline
      title: _jed('Warning')
      text: _jed("If you transfer an item to a different inventory pool it's not visible for you anymore.")
      type: "warning"

  validate: (e)=>
    unless App.Field.validate @form
      Notification.add_headline
        title: _jed('Error')
        text: _jed('Please provide all required fields')
        type: "error"
      do e.preventDefault
      return false
    else
      true

window.App.EditItemController = EditItemController