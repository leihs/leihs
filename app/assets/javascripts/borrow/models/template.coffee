window.App.Template.hasMany "lines", "App.TemplateLine", "template_id"

window.App.Template::groupedLines = ->
  groupedLines = _.groupBy App.Template.first().lines().all(), (l)-> 
    data = {start_date: l.start_date}
    data.inventory_pool = App.InventoryPool.find(l.inventory_pool_id).name if l.inventory_pool_id?
    data.inventory_pool_id = l.inventory_pool_id
    JSON.stringify data
  asArray = []
  for k, v of groupedLines
    lines = _.map v, (l)->
      l.start_date = JSON.parse(k).start_date
      return l
    data = {start_date: JSON.parse(k).start_date, lines: lines}
    if JSON.parse(k).inventory_pool_id?
      data.inventory_pool = App.InventoryPool.find JSON.parse(k).inventory_pool_id 
    asArray.push data
  return _.sortBy(asArray, (e)-> "#{e.start_date} #{if e.inventory_pool? then e.inventory_pool.name else ''}")