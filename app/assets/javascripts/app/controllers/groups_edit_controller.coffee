class GroupsEditController
  
  constructor: (options)->
    @el = $(options.el)
    @addUserInput = @el.find("#add-user")
    @addModelInput = @el.find("#add-model")
    do @delegateEvents

  delegateEvents: =>
    @el.find()
    @addUserInput.on "autocompleteselect", (e, ui)=> @addUser ui.item
    @addModelInput.on "autocompleteselect", (e, ui)=> @addModel ui.item
    @el.on "click", ".field-inline-entry .remove", (e) => @toggleRemove($(e.currentTarget).closest(".field-inline-entry"))

  addUser: (user)=> @addUserInput.closest(".field").append $.tmpl("app/views/groups/user_field_inline_entry", user)
  addModel: (model)=> @addModelInput.closest(".field").append $.tmpl("app/views/groups/partition_field_inline_entry", model)

  toggleRemove: (line)=>
    if line.hasClass "tobedeleted"
      line.removeClass "tobedeleted"
      line.find("span").removeClass "tobedeleted"
      line.find("input").removeAttr "disabled"
      line.find(".capacity").show()
      line.find(".remove").text _jed("Remove")
      line.find("[name*='_destroy']").val(null).attr("disabled", "disabled")
    else
      line.addClass "tobedeleted"
      line.find("span").addClass "tobedeleted"
      line.find("input").attr "disabled", "disabled"
      line.find(".capacity").hide()
      line.find(".remove").text _jed("undo")
      line.find("[name*='_destroy']").val("1").removeAttr("disabled")
      line.find("[name*='id']").removeAttr("disabled")

window.App.GroupsEditController = GroupsEditController