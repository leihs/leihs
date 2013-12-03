class window.App.ModelsPropertiesController extends Spine.Controller

  events:
    "click #add-property": "add"

  elements:
    ".list-of-lines": "list"

  constructor: ->
    super
    @list.sortable
      handle: "[data-type='sort-handle']"

  add: (e)=>
    e.preventDefault()
    @list.prepend App.Render "manage/views/models/form/property_inline_entry", {}, {uid: App.Model.uid("uid")}
    @list.find("input[type='text']:first").focus()