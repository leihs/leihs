class EditItemController

  el: "#item.edit"
  
  constructor: (options)->
    @el = $(@el)
    @form = @el.find "form"
    do @setupDatepicker
    do @delegateEvents
    do @setupDependentFields
    do @setupSoftValidation

  setupDatepicker: =>
    @el.find(".datepicker").datepicker().each (i,el)=> 
      el = $(el)
      value_el = el.prev("input[type=hidden]")
      el.val moment(value_el.val()).format(i18n.date.L) if value_el.val().length
      el.on "change", => value_el.val moment(el.val(), i18n.date.L).format("YYYY-MM-DD")
    
  delegateEvents: =>
    @form.find("input[name='item[owner_id]']").bind "change", ->
      if $(this).val() != $(this).data "initial_value"
        Notification.add_headline
          title: _jed('Warning')
          text: _jed('This item will be given to a different inventory pool and not show up in yours anymore!')
          type: "warning"

  setupDependentFields: =>
    do =>
      target = @form.find("[name='item[to_retire]']")
      field = @form.find("[name='item[retired_reason]']").closest(".field")
      check= => if target.is(":checked") then field.show() else field.hide()
      do check
      target.on "change", check
    do =>
      targets = @form.find("[name='item[properties][reference]']")
      target = @form.find("[name='item[properties][reference]'][value='investment']")
      field = @form.find("[name='item[properties][project_number]']").closest(".field")
      check= => if target.is(":checked") then field.show() else field.hide()
      do check
      targets.on "change", check

  setupSoftValidation: =>
    @form.on "submit", @validate

  validate: (e)=>
    valid = true
    @form.find(".invalid").removeClass("invalid")
    for mendatory_field in @form.find(".field.required:visible")
      if ($(mendatory_field).find("input[type=text]").length and $(mendatory_field).find("input[type=text]").val().length == 0) or 
      ($(mendatory_field).find("textarea").length and $(mendatory_field).find("textarea").val().length == 0) or 
      ($(mendatory_field).find("input[type=checkbox]").length and $(mendatory_field).find("input[type=checkbox]:checked").length == 0) or
      ($(mendatory_field).find("input[type=radio]").length and $(mendatory_field).find("input[type=radio]:checked").length == 0)
        valid = false 
        $(mendatory_field).addClass("invalid")

    if not valid
      Notification.add_headline
        title: _jed('Error')
        text: _jed('Please provide all required fields')
        type: "error"
      do e.preventDefault
      return false

window.App.EditItemController = EditItemController