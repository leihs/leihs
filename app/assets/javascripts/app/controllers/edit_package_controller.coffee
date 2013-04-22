class EditPackageController

  constructor: (options)->
    @package = options.package
    @saveCallback = options.saveCallback
    @packages = if @package? then @package.children else []
    @dialog = Dialog.add
      content: $.tmpl("app/views/packages/edit", {package: @package})
      dialogClass: "medium package-dialog"
    @packageItemsEl = @dialog.find("#package-items")
    @listOfItems = @dialog.find(".list")
    @autocomplete = @dialog.find(".autocomplete")
    @addItemform = @dialog.find("form#add-item")
    @saveButton = @dialog.find("button.save")
    @packageForm = @dialog.find("#form")
    @flashMessage = @dialog.find(".flash_message")
    do @delegateEvents
    packageFields = _.reject Fields, (f)->
      not _.include [9,10,11,15,17,18,19,20,5,6,12,13,14,25], f.id
    new App.EditItemController packageFields, @package
    Dialog.rescale(@dialog)

  delegateEvents: =>
    @autocomplete.on "autocompleteselect", (event, ui)=> @addItem(ui.item)
    @addItemform.on "submit", @submitAddItemForm
    @listOfItems.on "click", ".removeItem", (event)=> @removeItem $(event.currentTarget).tmplItem().data
    @saveButton.on "click", @savePackage

  addItem: (item)=>
    @flashMessage.hide()
    @autocomplete.val ""
    @packages.push item unless _.find(@packages, (i)-> i.inventory_code is item.inventory_code)
    do @renderItems

  removeItem: (item)=>
    @packages = _.reject @packages, (i)-> i is item
    do @renderItems

  renderItems: ->
    @packageItemsEl.html $.tmpl "app/views/packages/edit/item_line", @packages
    Dialog.rescale(@dialog)

  submitAddItemForm: (event)=>
    event.preventDefault()
    inventory_code = @autocomplete.val()
    @autocomplete.val("")
    @autocomplete.after LoadingImage.get()
    $.getJSON("/backend/inventory_pools/#{currentInventoryPool.id}/search?types[]=item&term=#{inventory_code}&with[model][name]=true")
      .done((data)=> @addItem(data[0]) if data? and data.length)
      .always(=> @autocomplete.next(".loading").remove())

  savePackage: =>
    if @packages.length
      @package = @packageForm.serializeObject().item
      @saveCallback(@packages, @package)
      @dialog.dialog "close"
    else
      @flashMessage.html(_jed("You can not create a package without any item")).show()
      Dialog.rescale(@dialog)

window.App.EditPackageController = EditPackageController