class GroupsNewController extends App.GroupsController

  delegateEvents: =>
    super
    @el.on "click", ".field-inline-entry .remove", @removeFieldInlineEntry

  removeFieldInlineEntry: -> do $(this).closest(".field-inline-entry").remove

window.App.GroupsNewController = GroupsNewController
