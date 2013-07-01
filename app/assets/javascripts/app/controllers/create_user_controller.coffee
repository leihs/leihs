class CreateUserController

  constructor: (options)->

    @el = $(options.el)
    @groups = options.groups

    @addGroupInput = @el.find("#add-group")

    @delegateEvents()


  delegateEvents: =>

    @addGroupInput.on "autocompleteselect", (e, ui) => @addGroup ui.item
    @el.on "click", ".field-inline-entry .remove", @removeFieldInlineEntry


  addGroup: (group) =>

    @addGroupInput.closest(".inner").find(".field-inline-entry:contains(#{group.name})").remove()

    field = @addGroupInput.closest(".field.text")
    target_element = field.children(".field-inline-entry:first")
    template = $.tmpl("app/views/users/group_field_inline_entry", group)

    if target_element.length
      target_element.before template
    else
      field.append template


  removeFieldInlineEntry: -> do $(this).closest(".field-inline-entry").remove


window.App.CreateUserController = CreateUserController
