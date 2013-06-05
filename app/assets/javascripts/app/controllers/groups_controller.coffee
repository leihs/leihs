class GroupsController

  constructor: (options)->
    @el = $(options.el)
    @addUserInput = @el.find("#add-user")
    @addModelInput = @el.find("#add-model")
    do @delegateEvents

  delegateEvents: =>
    @el.find()
    @addUserInput.on "autocompleteselect", (e, ui)=> @addUser ui.item
    @addModelInput.on "autocompleteselect", (e, ui)=> @addModel ui.item

  addUser: (user) =>
    field = @addUserInput.closest(".field")
    unless field.find(".field-inline-entry:contains(#{user.name})").length
      target_element = field.children(".field-inline-entry:first")
      template = $.tmpl("app/views/groups/user_field_inline_entry", user)
      if target_element.length
        target_element.before template
      else
        field.append template

  addModel: (model) =>
    unless @addModelInput.closest(".inner").find(".field-inline-entry:contains(#{model.name})").length
      field = @addModelInput.closest(".field.text")
      target_element = field.children(".field-inline-entry:first")
      template = $.tmpl("app/views/groups/partition_field_inline_entry", model)
      if target_element.length
        target_element.before template
      else
        field.append template

  removeFieldInlineEntry: -> do $(this).closest(".field-inline-entry").remove

window.App.GroupsController = GroupsController
