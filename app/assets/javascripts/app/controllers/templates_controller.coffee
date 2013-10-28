class TemplatesController

  constructor: (options)->
    @el = $(options.el)
    @addModelInput = @el.find("#add-model")
    do @delegateEvents

  delegateEvents: =>
    @el.find()
    @el.on "click", ".field-inline-entry .remove", (e) => @toggleRemove($(e.currentTarget).closest(".field-inline-entry"))
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

  addModel: (model) =>
    @add @addModelInput, "app/views/templates/model_field_inline_entry", model

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

window.App.TemplatesController = TemplatesController
