class window.App.InlineEntryRemoveController extends Spine.Controller

  events:
    "click [data-type='inline-entry'] [data-remove]": "remove"

  remove: (e) =>
    e.preventDefault()
    line = $(e.currentTarget).closest("[data-type='inline-entry']")
    line.trigger "inline-entry-remove", line
    if line.data("new")?
      line.remove()
      @removeCallback?(line)
    else
      @toggleDestroy line, $(e.currentTarget)

  toggleDestroy: (line, target) =>
    removeButton = target
    destroyInput = line.find("[name*='_destroy']")
    if line.data("destroyOnSave")?
      line.removeClass "striked"
      line.find("input:visible").prop("disabled", false)
      line.data("removedOnSaveInfo").remove()
      line.find("[data-disable-on-remove]").prop "disabled", false
      destroyInput.val(null) if destroyInput.length
      line.data "destroyOnSave", null
      target.text _jed "Remove"
      @unstrikeCallback?(line)
    else
      line.addClass "striked"
      line.find("input:visible").prop("disabled", true)
      template = $ App.Render "manage/views/inline_entries/removed_on_save_info"
      line.data "removedOnSaveInfo", template
      line.prepend template
      line.find("[data-disable-on-remove]").prop "disabled", true
      destroyInput.val(1) if destroyInput.length
      line.data "destroyOnSave", true
      target.text _jed "undo"
      @strikeCallback?(line)
