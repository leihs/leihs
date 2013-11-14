class window.App.ContractLinesEditController extends Spine.Controller

  events:
    "click [data-edit-lines]": "editLines"

  editLines: (e)=>
    trigger = $ e.currentTarget
    selectedLines = trigger.data("edit-lines") == "selected-lines" 
    ids = if selectedLines then App.LineSelectionController.selected else trigger.data "ids"
    contractLines = (App.ContractLine.find id for id in ids)
    mergedLines = App.Modules.HasLines.mergeLinesByModel contractLines
    quantity = if selectedLines 
        null 
      else 
        _.reduce mergedLines, (mem, l)-> 
          mem + (if l.sublines? then _.reduce(l.sublines, ((mem, l)-> mem+l.quantity), 0) else l.quantity)
        , 0
    models = _.unique _.map(_.filter(mergedLines, (l)->l.model_id?), (l)-> l.model()), false, (m) -> m.id
    new App.ContractLinesChangeController
      mergedLines: mergedLines
      lines: contractLines
      user: @user
      models: models
      quantity: quantity
      contract: @contract
      startDateDisabled: @startDateDisabled