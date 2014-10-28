class window.App.InventoryExpandController extends Spine.Controller

  events:
    "click [data-type='inventory-expander']":"toggle"

  toggle: (e)=>
    target = $ e.currentTarget
    if target.data("_expanded")? and target.data("_expanded") == true
      @close target
    else
      @open target

  close: (target)=>
    target.data "_expanded", false
    target.find(".arrow").removeClass("down right").addClass("right")
    line = target.closest("[data-id]")
    line.data("_children").detach()

  open: (target)=>
    target.data "_expanded", true
    target.find(".arrow").removeClass("down right").addClass("down")
    line = target.closest("[data-id]")
    if _.contains(["model", "software"], line.data("type")) and not line.data("_children")?
      @fetchData line, @updateChildren 
    @setupChildren(line)

  fetchData: (line, callback)=>
    model = App.Model.find(line.data("id")) if line.data("type") == "model"
    software = App.Software.find(line.data("id")) if line.data("type") == "software"
    itemIds = _.map (model?.items() ? software?.licenses()).all(), (i)->i.id
    @fetchCurrentItemLocation(line, itemIds).done => 
      @fetchPackageItems(line, itemIds).done (data)=>
        @fetchPackageModels(line, itemIds).done => callback line

  fetchCurrentItemLocation: (line, itemIds)=>
    App.CurrentItemLocation.ajaxFetch
      data: $.param
        ids: itemIds
        all: true
        paginate: false

  fetchPackageItems: (line, itemIds)=>
    if line.data("is_package") == true
      App.Item.ajaxFetch
        data: $.param
          package_ids: itemIds
          paginate: false
    else
      {done: (c)->c()}

  fetchPackageModels: (line, itemIds)=>
    if line.data("is_package") == true
      items = (App.Item.find(id) for id in itemIds)
      children = _.flatten _.map items, (i)->i.children().all()
      modelIds = _.uniq _.map children, (c)->c.model_id
      App.Model.ajaxFetch
        data: $.param
          ids: modelIds
          paginate: false
          include_package_models: true
    else
      {done: (c)->c()}

  setupChildren: (line)=>
    @renderChildren line unless line.data("_children")?
    line.after line.data "_children"    

  updateChildren: (line)=>
    currentContainer = line.data "_children"
    @renderChildren line, "additionalDataFetched"
    currentContainer.replaceWith line.data "_children"

  renderChildren: (line, additionalDataFetched = false)=>
    record = App[_.string.classify(line.data("type"))].find line.data("id")
    data = switch line.data("type")
      when "model"
        record.items().all()
      when "software"
        record.licenses().all()
      when "item"
        record.children().all()
    childrenContainer = $("<div class='group-of-lines'></div>")
    childrenContainer.html $(App.Render("manage/views/inventory/line", data, {additionalDataFetched: additionalDataFetched, accessRight: App.AccessRight, currentUserRole: App.User.current.role}))
    line.data "_children", childrenContainer
