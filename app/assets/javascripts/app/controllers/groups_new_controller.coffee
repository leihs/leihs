class GroupsNewController
  
  constructor: (options)->
    @el = $(options.el)
    @addUserInput = @el.find("#add-user")
    @addModelInput = @el.find("#add-model")
    do @delegateEvents

  delegateEvents: =>
    @el.find()
    @addUserInput.on "autocompleteselect", (e, ui)=> @addUser ui.item
    @addModelInput.on "autocompleteselect", (e, ui)=> @addModel ui.item
    @el.on "click", ".field-inline-entry .remove", @removeFieldInlineEntry

  addUser: (user)=> @addUserInput.closest(".field").append $.tmpl("app/views/groups/user_field_inline_entry", user)

  addModel: (model)=> @addModelInput.closest(".field").append $.tmpl("app/views/groups/partition_field_inline_entry", model)

  removeFieldInlineEntry: -> do $(this).closest(".field-inline-entry").remove

window.App.GroupsNewController = GroupsNewController