window.App.Order.url = => "/borrow/order"

window.App.Order::groupedAndMergedLines = ->
  merge = _.groupBy @lines().all(), (l)-> JSON.stringify({start_date: l.start_date, inventory_pool_id: l.inventory_pool_id})
  for k, v of merge
    merge[k] = _.chain(v)
                .sortBy((l)-> l.model().name)
                .groupBy((l)-> JSON.stringify {model_id: l.model_id, end_date: l.end_date})
                .value()
    merge[k] = _(merge[k]).values().map (array)->
      h =
        line_ids: _.map array, (l)-> l.id
        quantity: _.reduce array, ((mem, l)-> l.quantity+mem), 0
        model: _.first(array).model()
        start_date: _.first(array).start_date
        end_date: _.first(array).end_date
      h.available = ->
        _.all h.line_ids, (line_id) ->
          line = App.OrderLine.find line_id
          line["available?"]
      h
  result = []
  for k, v of merge
    result.push
      inventory_pool: App.InventoryPool.find JSON.parse(k).inventory_pool_id
      start_date: JSON.parse(k).start_date
      grouped_lines: v
  result = _.sortBy result, (e)-> e.start_date
  console.log result
  return result
