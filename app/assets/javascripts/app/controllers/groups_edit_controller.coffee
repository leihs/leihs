class GroupsEditController extends App.GroupsController

  delegateEvents: =>
    super
    @el.on "click", ".field-inline-entry .remove", (e) => @toggleRemove($(e.currentTarget).closest(".field-inline-entry"))

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
