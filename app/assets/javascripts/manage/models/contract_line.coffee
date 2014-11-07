## Global

window.App.ContractLine.url = => "/manage/#{App.InventoryPool.current.id}/contract_lines"

window.App.ContractLine.createOne = (data)->
  $.post("/manage/#{App.InventoryPool.current.id}/contract_lines", data)
  .done (contractLine)->
    App.ContractLine.addRecord new App.ContractLine contractLine
    App.Contract.trigger "refresh"

window.App.ContractLine.createForTemplate = (data)->
  $.post("/manage/#{App.InventoryPool.current.id}/contract_lines/for_template", data)
  .done (contractLines)->
    records = for contractLine in contractLines
      App.ContractLine.addRecord new App.ContractLine contractLine
    App.Model.ajaxFetch
      data: $.param
        template_id: data.template_id
        paginate: false 
    .done =>
      App.Contract.trigger "refresh"

window.App.ContractLine.destroyMultiple = (ids)->
  App.ContractLine.find(id).remove() for id in ids
  $.ajax
    url: "/manage/#{App.InventoryPool.current.id}/contract_lines/"
    type: "post"
    data: 
      line_ids: ids
      _method: "delete"
  App.ContractLine.trigger "destroy", ids

window.App.ContractLine.changeTimeRange = (lines, startDate, endDate)=>
  startDate = moment(startDate).format("YYYY-MM-DD") if startDate
  endDate = moment(endDate).format("YYYY-MM-DD")
  for line in lines
    data = {end_date: endDate}
    data["start_date"] = startDate if startDate
    line.refresh data
  $.post "/manage/#{App.InventoryPool.current.id}/contract_lines/change_time_range",
    line_ids: _.map(lines,(l)->l.id)
    start_date: startDate
    end_date: endDate
  .done => App.Contract.trigger "refresh"

window.App.ContractLine.assignOrCreate = (data)->
  $.post("/manage/#{App.InventoryPool.current.id}/contract_lines/assign_or_create", data)

window.App.ContractLine.takeBack = (lines, returnedQuantity)->
  $.post "/manage/#{App.InventoryPool.current.id}/contract_lines/take_back", 
    ids: (line.id for line in lines)
    returned_quantity: returnedQuantity

window.App.ContractLine.swapUser = (lines, userId)-> 
  $.post "/manage/#{App.InventoryPool.current.id}/contract_lines/swap_user", 
    line_ids: (line.id for line in lines)
    user_id: userId

Spine.Model.include.call App.ContractLine, App.Modules.LineProblems

## Prototype

window.App.ContractLine::assign = (item, callback = null)->
  $.post("/manage/#{App.InventoryPool.current.id}/contract_lines/#{@id}/assign", {inventory_code: item.inventory_code})
  .fail (e)=>
    App.Flash
      type: "error"
      message: e.responseText
  .done (data)=>
    @refresh data
    App.ContractLine.trigger "update", @
    App.Flash
      type: "success"
      message: _jed "%s assigned to %s", [item.inventory_code, (item.model() ? item.software()).name()]
    callback?()

window.App.ContractLine::removeAssignment = ->
  $.post("/manage/#{App.InventoryPool.current.id}/contract_lines/#{@id}/remove_assignment")
  @refresh {item_id: null}
  App.ContractLine.trigger "update", @
