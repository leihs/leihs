class window.App.ItemInspectDialogController extends Spine.Controller

  events:
    "submit form": "submit"

  elements:
    "form": "form"

  constructor: (data)->
    @setupModal data.item
    super

  setupModal: (item)=>
    @el = $ App.Render "manage/views/items/inspect_dialog", item
    @modal = new App.Modal @el

  submit: (e)=>
    e.preventDefault()
    data = {}
    for datum in @form.serializeArray()
       data[datum.name] = JSON.parse datum.value
    @item.inspect(data)
    .done => @modal.destroy true
    