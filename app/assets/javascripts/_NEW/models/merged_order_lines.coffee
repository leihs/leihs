###
  
  MergedOrderLines

###

class window.App.MergedOrderLines extends Spine.Model

  @configure "MergedOrderLines"

  constructor: (lines)->
    super
    @line_ids = _.map lines, (l)-> l.id
    @quantity = _.reduce lines, ((mem, l)-> l.quantity+mem), 0
    @model = _.first(lines).model()
    @start_date = _.first(lines).start_date
    @end_date = _.first(lines).end_date

  available: =>
    _.all @line_ids, (line_id) =>
      line = App.OrderLine.find line_id
      line["available?"]