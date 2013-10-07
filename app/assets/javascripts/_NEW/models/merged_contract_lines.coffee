###
  
  MergedContractLines

###

class window.App.MergedContractLines extends Spine.Model

  @configure "MergedContractLines"

  constructor: (lines)->
    super
    @line_ids = _.map lines, (l)-> l.id
    @quantity = _.reduce lines, ((mem, l)-> l.quantity+mem), 0
    @model = _.first(lines).model()
    @start_date = _.first(lines).start_date
    @end_date = _.first(lines).end_date

  available: =>
    _.all @line_ids, (line_id) =>
      line = App.ContractLine.find line_id
      if line["available?"]?
        line["available?"]
      else
        true