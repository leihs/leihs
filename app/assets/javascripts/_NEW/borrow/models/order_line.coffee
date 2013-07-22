window.App.OrderLine.url = => "/borrow/order_lines"

# our backend responds with multiple lines when creating one order line (e.g. with quantity of 2)
# so we have to split those make both available but only respond with one
window.App.OrderLine.fromJSON = (data) ->
  data = Spine.Model.fromJSON.call window.App.OrderLine, data
  if _.isArray data
    App.OrderLine.records[record.id] = record for record in data 
    data.attributes = => {_remove: true}
  return data

window.App.OrderLine::updateAttributes = (atts, options) ->
  if atts? and atts["_remove"]
    delete App.OrderLine.records[@id]
  else
    Spine.Model::updateAttributes(atts, options)

window.App.OrderLine.changeTimeRange = (lines, startDate, endDate, inventoryPool)=>
  startDate = moment(startDate).format("YYYY-MM-DD")
  endDate = moment(endDate).format("YYYY-MM-DD")
  for line in lines
    line.start_date = startDate
    line.end_date = endDate
    line.inventory_pool_id = inventoryPool.id
    App.OrderLine.records[line.id] = line
  $.post "/borrow/order_lines/change_time_range",  
    line_ids: _.map(lines,(l)->l.id)
    start_date: startDate
    end_date: endDate
    inventory_pool_id: inventoryPool.id