class window.App.LinesCellTooltipController extends Spine.Controller

  events:
    "mouseenter [data-type='lines-cell']": "onEnter"

  onEnter: (e)=>
    trigger = $(e.currentTarget)
    record = if trigger.closest(".line[data-type='contract']").length 
      App.Contract.findOrBuild(trigger.closest(".line[data-type='contract']").data())
    else if trigger.closest(".line[data-type='take_back']").length 
      App.Visit.findOrBuild(trigger.closest(".line[data-type='take_back']").data())
    else if trigger.closest(".line[data-type='hand_over']").length 
      App.Visit.findOrBuild(trigger.closest(".line[data-type='hand_over']").data())
    tooltip = new App.Tooltip
      el: trigger.closest(".line-col")
      content: App.Render "views/loading", {size: "micro"}
    @fetchData record, => tooltip.update App.Render "manage/views/lines/tooltip", record

  fetchData: (record, callback)=>
    modelIds = []
    optionIds = []
    for line in record.lines().all()
      if line.model_id?
        modelIds.push(line.model_id) unless App.Model.exists(line.model_id)?
      else if line.option_id?
        optionIds.push(line.option_id) unless App.Option.exists(line.option_id)?
    @fetchModels(modelIds).done => @fetchOptions(optionIds).done => do callback

  fetchModels: (ids)=>
    if ids.length
      App.Model.ajaxFetch
        data: $.param
          ids: ids
    else
      {done: (c)->c()}

  fetchOptions: (ids)=>
    if ids.length
      App.Option.ajaxFetch
        data: $.param
          ids: ids
    else
      {done: (c)->c()}