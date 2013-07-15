window.App.OrderLine.url = => "/borrow/order_lines"

# our backend responds with multiple lines when creating one order line (e.g. with quantity of 2)
# so we have to split those make both available but only respond with one
window.App.OrderLine.fromJSON = (data) ->
  data = Spine.Model.fromJSON.call window.App.OrderLine, data
  if _.isArray data
    App.OrderLine.records[record.id] = record for record in data 
    data.attributes = => 
      _.first Spine.Model.toJSON(data)
  return data