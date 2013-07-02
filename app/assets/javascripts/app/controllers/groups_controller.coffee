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

  add: (inputField, tmpl, data) =>    
    line = inputField.closest(".inner").find(".field-inline-entry:contains(#{data.name})").detach()

    field = inputField.closest(".field.text")
    target_element = field.children(".field-inline-entry:first")

    new_line = if line.length
      line
    else
      $.tmpl(tmpl, data)

    if target_element.length
      target_element.before new_line
    else
      field.append new_line

  addUser: (user) =>
    @add @addUserInput, "app/views/groups/user_field_inline_entry", user

  addModel: (model) =>
    @add @addModelInput, "app/views/groups/partition_field_inline_entry", model

  removeFieldInlineEntry: -> do $(this).closest(".field-inline-entry").remove

window.App.GroupsController = GroupsController
