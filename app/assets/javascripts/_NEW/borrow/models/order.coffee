window.App.Order.url = => "/borrow/order"

window.App.Order::groupedAndMergedLines = ->
  merge = _.groupBy @lines().all(), (l)-> JSON.stringify({start_date: l.start_date, inventory_pool_id: l.inventory_pool_id})
  for k, v of merge
    merge[k] = _.chain(v)
                .sortBy((l)-> l.model().name)
                .groupBy((l)-> JSON.stringify {model_id: l.model_id, end_date: l.end_date})
                .value()
    merge[k] = _(merge[k]).values().map (lines)-> new App.MergedOrderLines lines
  result = []
  for k, v of merge
    result.push
      inventory_pool: App.InventoryPool.find JSON.parse(k).inventory_pool_id
      start_date: JSON.parse(k).start_date
      merged_lines: v
  result = _.sortBy result, (e)-> e.start_date
  return result
