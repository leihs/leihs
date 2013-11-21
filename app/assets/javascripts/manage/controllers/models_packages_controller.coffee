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
      done: @saveNotExistingPackage
      children: []

  saveNotExistingPackage: (data, children, entry)=>
    entry.remove() if entry?
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
        for: "flexibleFields"

  fetchChildren: (item)=>
    App.Item.ajaxFetch
      data: $.param
        package_ids: [item.id]
        paginate: false

  saveExistingPackage: (data, children, entry)=>
    @list.prepend entry
    item = App.Item.find entry.data("id")
    formData = entry.find("[data-type='form-data']")
    entry.find("[data-type='updated-text']").removeClass "hidden"
    formData.html App.Render "manage/views/models/form/package_inline_entry/updated_package_form_data", {children: children, data: data, item: item}, {uid: item.id}

  editNewPackage: (entry)=>
    data = App.ElementFormDataAsObject entry  
    new App.ModelsPackageDialogController
      item: data
      done: @saveNotExistingPackage
      children: _.map data.children, (c)-> App.Item.find c.id
      entry: entry