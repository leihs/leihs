class window.App.ModelsPackagesController extends Spine.Controller

  events:
    "click #add-package": "createPackage"
    "click [data-edit-package]": "editPackage"

  elements:
    ".list-of-lines": "list"
    "#add-package": "addPackageButton"

  constructor: ->
    super

  createPackage: =>
    new App.ModelsPackageDialogController
      item: new App.Item($(@addPackageButton).data())
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
    id = entry.data("id")
    @fetchItem(id)
    .done (itemData)=>
      @fetchChildren(id).done (data)=>
        children = (App.Item.find datum.id for datum in data)
        @fetchModels(children).done => callback(itemData, children)

  fetchModels: (items)=>
    ids = (item.model_id for item in items)
    return {done: (c)->c()} unless ids.length
    App.Model.ajaxFetch
      data: $.param
        ids: ids
        paginate: false
        include_package_models: true

  fetchItem: (id)=>
    $.get App.Item.url()+"/#{id}",
      for: "flexibleFields"

  fetchChildren: (id)=>
    App.Item.ajaxFetch
      data: $.param
        package_ids: [id]
        paginate: false

  saveExistingPackage: (itemData, children, entry)=>
    @list.prepend entry
    entry.find("[data-type='updated-text']").removeClass "hidden"
    entry.find("[data-type='form-data']").html ->
      App.Render "manage/views/models/form/package_inline_entry/updated_package_form_data", {children: children, data: itemData}, {uid: entry.data("id")}

  editNewPackage: (entry)=>
    data = App.ElementFormDataAsObject entry  
    new App.ModelsPackageDialogController
      item: data
      done: @saveNotExistingPackage
      children: _.map data.children, (c)-> App.Item.find c.id
      entry: entry