class window.App.ModelsPackagesController extends Spine.Controller

  events:
    "click #add-package": "createPackage"
    "click [data-edit-package]": "editPackage"

  elements:
    ".list-of-lines": "list"

  constructor: ->
    super

  createPackage: =>
    new App.ModelsPackageDialogController
      item: new App.Item
      done: @saveNewPackage
      children: []

  saveNewPackage: (data, children)=>
    @list.prepend App.Render "manage/views/models/form/package_inline_entry", {children: children, data: data}, {uid: App.Model.uid("uid")}

  editPackage: (e)=>
    target = $ e.currentTarget
    inlineEntry = target.closest "[data-type='inline-entry']"
    if inlineEntry.data("id")?
      @editExistingPackage inlineEntry
    else 
      @editNewPackage inlineEntry

  editExistingPackage: (entry)=>
    modal = new App.Modal "<div>"
    modal.undestroyable()
    @getRemoteItemData entry, (item, children)=>
      modal.destroyable().destroy()
      new App.ModelsPackageDialogController
        item: item
        children: children
        done: @saveExistingPackage
        entry: entry

  getLocalItemData: (entry, callback)=>
    data = App.ElementFormDataAsObject entry
    callback(data, entry.data("children"))

  getRemoteItemData: (entry, callback)=>
    @fetchItem(entry.data("id"))
    .done =>
      item = App.Item.find entry.data "id"
      @fetchChildren(item).done =>
        children = item.children().all()
        @fetchModels(children).done => callback(item, item.children().all())

  fetchModels: (items)=>
    ids = (item.model_id for item in items)
    return {done: (c)->c()} unless ids.length
    App.Model.ajaxFetch
      data: $.param
        ids: ids
        paginate: false
        include_package_models: true

  fetchItem: (id)=>
    App.Item.ajaxFetch
      data: $.param
        id: id

  fetchChildren: (item)=>
    App.Item.ajaxFetch
      data: $.param
        package_ids: [item.id]
        paginate: false

  saveExistingPackage: (data, children, entry)=>
    @list.prepend entry
    item = App.Item.find entry.data("id")
    formData = entry.find("[data-type='form-data']")
    entry.data "updated", true
    entry.data "children", children
    entry.find("[data-type='updated-text']").removeClass "hidden"
    formData.html App.Render "manage/views/models/form/package_inline_entry/updated_package_form_data", {children: children, data: data, item: item}, {uid: item.id}

  editNewPackage: (entry)=>
    new App.ModelsPackageDialogController
      item: @getLocalItemData entry
      done: @saveNewPackage
      children: []