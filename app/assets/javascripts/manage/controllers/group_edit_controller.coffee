class window.App.GroupEditController extends App.GroupController

  @include App.Modules.InlineEntryHandlers

  removeUserHandler: @::strikeRemoveUserHandler

  removePartitionHandler: (e) =>
    e.preventDefault()
    removeButton = $(e.currentTarget)
    line = removeButton.closest ".line"
    modelName = line.find "[data-model-name]"

    if modelName.hasClass "striked"
      modelName.removeClass "striked"
      line.find("[data-quantities]").removeClass("hidden")
      removeButton.text _jed("Remove")
      line.find("[name*='_destroy']").val(null)
    else
      modelName.addClass "striked"
      line.find("[data-quantities]").addClass("hidden")
      removeButton.text _jed("undo")
      line.find("[name*='_destroy']").val(1)
