class window.App.GroupEditController extends App.GroupController

  removeUserHandler: (e) =>
    e.preventDefault()
    removeButton = $(e.currentTarget)
    line = removeButton.closest ".line"
    userName = line.find "[data-user-name]"

    if userName.hasClass "striked"
      userName.removeClass "striked"
      removeButton.text _jed("Remove")
      line.find("[name*='_destroy']").val(null)
    else
      userName.addClass "striked"
      removeButton.text _jed("undo")
      line.find("[name*='_destroy']").val(1)

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
