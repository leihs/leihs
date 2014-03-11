App.Modules.InlineEntryHandlers =

  strikeRemoveUserHandler: (e) ->
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
