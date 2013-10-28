window.App.ContractLine.url = => "/borrow/contract_lines"

# our backend responds with multiple lines when creating one contract line (e.g. with quantity of 2)
# so we have to split those make both available but only respond with one
window.App.ContractLine.fromJSON = (data) ->
  new_lines = Spine.Model.fromJSON.call window.App.ContractLine, data.new_lines
  if _.isArray new_lines
    App.ContractLine.records[record.id] = record for record in new_lines
    new_lines.attributes = => {_remove: true}
  if data.contract and not App.Contract.exists(data.contract.id)
    target_contract =  new App.Contract data.contract
    App.Contract.currents.push(App.Contract.records[target_contract.id] = target_contract)
  return new_lines

window.App.ContractLine::updateAttributes = (atts, options) ->
  if atts? and atts["_remove"]
    delete App.ContractLine.records[@id]
  else
    Spine.Model::updateAttributes(atts, options)

window.App.ContractLine.changeTimeRange = (lines, startDate, endDate, inventoryPool)=>
  startDate = moment(startDate).format("YYYY-MM-DD")
  endDate = moment(endDate).format("YYYY-MM-DD")
  for line in lines
    line.start_date = startDate
    line.end_date = endDate
    line.inventory_pool_id = inventoryPool.id
    App.ContractLine.records[line.id] = line
  $.post "/borrow/contract_lines/change_time_range",
    line_ids: _.map(lines,(l)->l.id)
    start_date: startDate
    end_date: endDate
    inventory_pool_id: inventoryPool.id