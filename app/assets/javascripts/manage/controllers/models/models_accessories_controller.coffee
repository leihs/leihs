class window.App.ModelsAccessoriesController extends Spine.Controller

  events:
    "click #add-accessory": "add"
    "keypress #accessory-name": "enter"

  elements:
    "input#accessory-name": "input"
    ".list-of-lines": "list"

  enter: (e)=>
    if e.keyCode == $.ui.keyCode.ENTER
      e.preventDefault()
      @add ({preventDefault: -> null})

  add: (e)=>
    e.preventDefault()
    name = @input.val()
    unless @list.find("[data-name='#{name}']").length
      @list.prepend App.Render "manage/views/models/form/accessory_inline_entry", {name: name}, {uid: App.Model.uid("uid")}
    @input.val("").blur()